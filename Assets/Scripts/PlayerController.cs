using System.Collections;
using UnityEngine;

namespace ProjectVesper.Combat
{
    [RequireComponent(typeof(CharacterController))]
    [RequireComponent(typeof(Health))]
    [RequireComponent(typeof(Stamina))]
    public sealed class PlayerController : MonoBehaviour
    {
        [Header("Movement")]
        [SerializeField] private float moveSpeed = 6f;
        [SerializeField] private float rotationSpeed = 18f;
        [SerializeField] private bool cameraRelativeMovement = true;

        [Header("Dodge")]
        [SerializeField] private float dodgeSpeed = 15f;
        [SerializeField] private float dodgeDuration = 0.18f;
        [SerializeField] private float dodgeStaminaCost = 24f;

        [Header("Attacks")]
        [SerializeField] private Transform attackOrigin;
        [SerializeField] private LayerMask enemyLayers;
        [SerializeField] private float lightAttackDamage = 18f;
        [SerializeField] private float heavyAttackDamage = 36f;
        [SerializeField] private float lightAttackRange = 1.55f;
        [SerializeField] private float heavyAttackRange = 1.9f;
        [SerializeField] private float lightAttackRadius = 0.75f;
        [SerializeField] private float heavyAttackRadius = 0.95f;
        [SerializeField] private float lightAttackStaminaCost = 12f;
        [SerializeField] private float heavyAttackStaminaCost = 28f;
        [SerializeField] private float lightAttackCooldown = 0.28f;
        [SerializeField] private float heavyAttackCooldown = 0.55f;

        private CharacterController controller;
        private Stamina stamina;
        private Health health;
        private Camera mainCamera;
        private Vector3 moveDirection;
        private Vector3 lastFacing = Vector3.forward;
        private bool isDodging;
        private float nextAttackTime;

        private void Awake()
        {
            controller = GetComponent<CharacterController>();
            stamina = GetComponent<Stamina>();
            health = GetComponent<Health>();
            mainCamera = Camera.main;

            if (attackOrigin == null)
            {
                attackOrigin = transform;
            }
        }

        private void Update()
        {
            if (health.IsDead)
            {
                return;
            }

            ReadMovementInput();
            RotateTowardMovement();
            HandleMovement();
            HandleActions();
        }

        private void ReadMovementInput()
        {
            Vector2 input = new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));
            input = Vector2.ClampMagnitude(input, 1f);

            Vector3 forward = Vector3.forward;
            Vector3 right = Vector3.right;

            if (cameraRelativeMovement && mainCamera != null)
            {
                forward = Vector3.ProjectOnPlane(mainCamera.transform.forward, Vector3.up).normalized;
                right = Vector3.ProjectOnPlane(mainCamera.transform.right, Vector3.up).normalized;
            }

            moveDirection = (right * input.x + forward * input.y).normalized;

            if (moveDirection.sqrMagnitude > 0.001f)
            {
                lastFacing = moveDirection;
            }
        }

        private void RotateTowardMovement()
        {
            if (lastFacing.sqrMagnitude <= 0.001f)
            {
                return;
            }

            Quaternion targetRotation = Quaternion.LookRotation(lastFacing, Vector3.up);
            transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);
        }

        private void HandleMovement()
        {
            if (isDodging)
            {
                return;
            }

            controller.SimpleMove(moveDirection * moveSpeed);
        }

        private void HandleActions()
        {
            if (Input.GetKeyDown(KeyCode.Space))
            {
                TryDodge();
            }

            if (Input.GetMouseButtonDown(0))
            {
                TryAttack(lightAttackDamage, lightAttackRange, lightAttackRadius, lightAttackStaminaCost, lightAttackCooldown);
            }

            if (Input.GetMouseButtonDown(1))
            {
                TryAttack(heavyAttackDamage, heavyAttackRange, heavyAttackRadius, heavyAttackStaminaCost, heavyAttackCooldown);
            }
        }

        private void TryDodge()
        {
            if (isDodging || !stamina.TrySpend(dodgeStaminaCost))
            {
                return;
            }

            Vector3 dodgeDirection = moveDirection.sqrMagnitude > 0.001f ? moveDirection : lastFacing;
            StartCoroutine(DodgeRoutine(dodgeDirection.normalized));
        }

        private IEnumerator DodgeRoutine(Vector3 dodgeDirection)
        {
            isDodging = true;
            float elapsed = 0f;

            while (elapsed < dodgeDuration)
            {
                controller.Move(dodgeDirection * (dodgeSpeed * Time.deltaTime));
                elapsed += Time.deltaTime;
                yield return null;
            }

            isDodging = false;
        }

        private void TryAttack(float damage, float range, float radius, float staminaCost, float cooldown)
        {
            if (Time.time < nextAttackTime || !stamina.TrySpend(staminaCost))
            {
                return;
            }

            nextAttackTime = Time.time + cooldown;
            Vector3 center = attackOrigin.position + transform.forward * range;
            Collider[] hits = Physics.OverlapSphere(center, radius, enemyLayers, QueryTriggerInteraction.Ignore);

            foreach (Collider hit in hits)
            {
                if (hit.TryGetComponent(out Health targetHealth))
                {
                    targetHealth.TakeDamage(damage);
                }
            }
        }

        private void OnDrawGizmosSelected()
        {
            Transform origin = attackOrigin != null ? attackOrigin : transform;
            Gizmos.color = Color.yellow;
            Gizmos.DrawWireSphere(origin.position + transform.forward * lightAttackRange, lightAttackRadius);
            Gizmos.color = new Color(1f, 0.45f, 0f);
            Gizmos.DrawWireSphere(origin.position + transform.forward * heavyAttackRange, heavyAttackRadius);
        }
    }
}

