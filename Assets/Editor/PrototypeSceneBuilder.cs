using ProjectVesper.Combat;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.UI;

namespace ProjectVesper.EditorTools
{
    public static class PrototypeSceneBuilder
    {
        private const int PlayerLayer = 8;
        private const int EnemyLayer = 9;

        [MenuItem("Tools/Project Vesper/Create Prototype Scene")]
        public static void CreatePrototypeScene()
        {
            if (!ConfirmSceneReset())
            {
                return;
            }

            ClearCurrentSceneObjects();

            EnsureLayer(PlayerLayer, "Player");
            EnsureLayer(EnemyLayer, "Enemy");

            GameObject arena = GameObject.CreatePrimitive(PrimitiveType.Cube);
            arena.name = "Arena";
            arena.transform.position = new Vector3(0f, -0.05f, 0f);
            arena.transform.localScale = new Vector3(18f, 0.1f, 18f);
            arena.GetComponent<Renderer>().sharedMaterial = CreateMaterial("Arena_Mat", new Color(0.18f, 0.2f, 0.22f));

            GameObject player = CreateCapsuleActor("Player", new Vector3(-3f, 1f, 0f), PlayerLayer, new Color(0.2f, 0.62f, 1f), 100f);
            player.tag = "Player";
            Stamina playerStamina = player.AddComponent<Stamina>();
            PlayerController playerController = player.AddComponent<PlayerController>();
            Health playerHealth = player.GetComponent<Health>();

            GameObject enemy = CreateCapsuleActor("Enemy", new Vector3(3f, 1f, 0f), EnemyLayer, new Color(1f, 0.25f, 0.2f), 180f);
            EnemyController enemyController = enemy.AddComponent<EnemyController>();
            Health enemyHealth = enemy.GetComponent<Health>();

            SerializedObject playerControllerObject = new SerializedObject(playerController);
            playerControllerObject.FindProperty("enemyLayers").intValue = 1 << EnemyLayer;
            playerControllerObject.ApplyModifiedPropertiesWithoutUndo();

            SerializedObject enemyControllerObject = new SerializedObject(enemyController);
            enemyControllerObject.FindProperty("target").objectReferenceValue = player.transform;
            enemyControllerObject.FindProperty("playerLayers").intValue = 1 << PlayerLayer;
            enemyControllerObject.ApplyModifiedPropertiesWithoutUndo();

            Camera camera = CreateCamera(player.transform);
            CreateDirectionalLight();
            CreateHud(playerHealth, enemyHealth, playerStamina);

            Selection.activeGameObject = player;
            SceneView.lastActiveSceneView?.FrameSelected();
            EditorUtility.SetDirty(camera.gameObject);
            EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
        }

        private static GameObject CreateCapsuleActor(string name, Vector3 position, int layer, Color color, float maxHealth)
        {
            GameObject actor = GameObject.CreatePrimitive(PrimitiveType.Capsule);
            actor.name = name;
            actor.layer = layer;
            actor.transform.position = position;
            actor.GetComponent<Renderer>().sharedMaterial = CreateMaterial($"{name}_Mat", color);

            CapsuleCollider collider = actor.GetComponent<CapsuleCollider>();
            Object.DestroyImmediate(collider);

            CharacterController controller = actor.AddComponent<CharacterController>();
            controller.height = 2f;
            controller.radius = 0.5f;
            controller.center = Vector3.zero;

            Health health = actor.AddComponent<Health>();
            SerializedObject healthObject = new SerializedObject(health);
            healthObject.FindProperty("maxHealth").floatValue = maxHealth;
            healthObject.ApplyModifiedPropertiesWithoutUndo();

            return actor;
        }

        private static Camera CreateCamera(Transform target)
        {
            GameObject cameraObject = new GameObject("Main Camera");
            cameraObject.tag = "MainCamera";
            Camera camera = cameraObject.AddComponent<Camera>();
            camera.fieldOfView = 45f;
            camera.nearClipPlane = 0.1f;
            camera.farClipPlane = 200f;

            CameraFollow follow = cameraObject.AddComponent<CameraFollow>();
            follow.SetTarget(target);
            cameraObject.transform.position = target.position + new Vector3(0f, 8.5f, -8.5f);
            cameraObject.transform.LookAt(target.position + Vector3.up * 1.1f);
            return camera;
        }

        private static void CreateDirectionalLight()
        {
            GameObject lightObject = new GameObject("Directional Light");
            Light light = lightObject.AddComponent<Light>();
            light.type = LightType.Directional;
            light.intensity = 1.2f;
            lightObject.transform.rotation = Quaternion.Euler(50f, -35f, 0f);
        }

        private static void CreateHud(Health playerHealth, Health enemyHealth, Stamina playerStamina)
        {
            GameObject canvasObject = new GameObject("Combat HUD");
            Canvas canvas = canvasObject.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            canvasObject.AddComponent<CanvasScaler>();
            canvasObject.AddComponent<GraphicRaycaster>();

            CombatHud hud = canvasObject.AddComponent<CombatHud>();
            Text playerHealthText = CreateHudText(canvasObject.transform, "Player HP", new Vector2(16f, -16f));
            Text enemyHealthText = CreateHudText(canvasObject.transform, "Enemy HP", new Vector2(16f, -44f));
            Text staminaText = CreateHudText(canvasObject.transform, "Stamina", new Vector2(16f, -72f));

            SerializedObject hudObject = new SerializedObject(hud);
            hudObject.FindProperty("playerHealth").objectReferenceValue = playerHealth;
            hudObject.FindProperty("enemyHealth").objectReferenceValue = enemyHealth;
            hudObject.FindProperty("playerStamina").objectReferenceValue = playerStamina;
            hudObject.FindProperty("playerHealthText").objectReferenceValue = playerHealthText;
            hudObject.FindProperty("enemyHealthText").objectReferenceValue = enemyHealthText;
            hudObject.FindProperty("staminaText").objectReferenceValue = staminaText;
            hudObject.ApplyModifiedPropertiesWithoutUndo();
            hud.Bind(playerHealth, enemyHealth, playerStamina);
        }

        private static Text CreateHudText(Transform parent, string name, Vector2 anchoredPosition)
        {
            GameObject textObject = new GameObject(name);
            textObject.transform.SetParent(parent, false);

            RectTransform rect = textObject.AddComponent<RectTransform>();
            rect.anchorMin = new Vector2(0f, 1f);
            rect.anchorMax = new Vector2(0f, 1f);
            rect.pivot = new Vector2(0f, 1f);
            rect.anchoredPosition = anchoredPosition;
            rect.sizeDelta = new Vector2(320f, 26f);

            Text text = textObject.AddComponent<Text>();
            text.font = Resources.GetBuiltinResource<Font>("Arial.ttf");
            text.fontSize = 18;
            text.color = Color.white;
            text.alignment = TextAnchor.MiddleLeft;
            text.raycastTarget = false;
            return text;
        }

        private static Material CreateMaterial(string name, Color color)
        {
            Material material = new Material(Shader.Find("Standard"));
            material.name = name;
            material.color = color;
            return material;
        }

        private static void ClearCurrentSceneObjects()
        {
            GameObject[] objects = Object.FindObjectsOfType<GameObject>();
            foreach (GameObject sceneObject in objects)
            {
                Object.DestroyImmediate(sceneObject);
            }
        }

        private static bool ConfirmSceneReset()
        {
            if (Object.FindObjectsOfType<GameObject>().Length == 0)
            {
                return true;
            }

            return EditorUtility.DisplayDialog(
                "Create Prototype Scene",
                "Current scene objects will be removed before creating the prototype arena.",
                "Create",
                "Cancel");
        }

        private static void EnsureLayer(int index, string layerName)
        {
            Object[] tagManagerAssets = AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/TagManager.asset");
            if (tagManagerAssets.Length == 0)
            {
                return;
            }

            SerializedObject tagManager = new SerializedObject(tagManagerAssets[0]);
            SerializedProperty layers = tagManager.FindProperty("layers");

            SerializedProperty layer = layers.GetArrayElementAtIndex(index);
            if (string.IsNullOrEmpty(layer.stringValue))
            {
                layer.stringValue = layerName;
                tagManager.ApplyModifiedPropertiesWithoutUndo();
            }
        }
    }
}
