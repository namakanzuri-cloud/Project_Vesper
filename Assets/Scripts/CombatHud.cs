using UnityEngine;
using UnityEngine.UI;

namespace ProjectVesper.Combat
{
    public sealed class CombatHud : MonoBehaviour
    {
        [SerializeField] private Health playerHealth;
        [SerializeField] private Health enemyHealth;
        [SerializeField] private Stamina playerStamina;
        [SerializeField] private Text playerHealthText;
        [SerializeField] private Text enemyHealthText;
        [SerializeField] private Text staminaText;

        public void Bind(Health player, Health enemy, Stamina stamina)
        {
            playerHealth = player;
            enemyHealth = enemy;
            playerStamina = stamina;
            Subscribe();
            RefreshAll();
        }

        private void Awake()
        {
            Subscribe();
            RefreshAll();
        }

        private void Start()
        {
            RefreshAll();
        }

        private void OnDestroy()
        {
            if (playerHealth != null)
            {
                playerHealth.Changed -= OnPlayerHealthChanged;
            }

            if (enemyHealth != null)
            {
                enemyHealth.Changed -= OnEnemyHealthChanged;
            }

            if (playerStamina != null)
            {
                playerStamina.Changed -= OnStaminaChanged;
            }
        }

        private void Subscribe()
        {
            if (playerHealth != null)
            {
                playerHealth.Changed -= OnPlayerHealthChanged;
                playerHealth.Changed += OnPlayerHealthChanged;
            }

            if (enemyHealth != null)
            {
                enemyHealth.Changed -= OnEnemyHealthChanged;
                enemyHealth.Changed += OnEnemyHealthChanged;
            }

            if (playerStamina != null)
            {
                playerStamina.Changed -= OnStaminaChanged;
                playerStamina.Changed += OnStaminaChanged;
            }
        }

        private void RefreshAll()
        {
            if (playerHealth != null)
            {
                OnPlayerHealthChanged(playerHealth.CurrentHealth, playerHealth.MaxHealth);
            }

            if (enemyHealth != null)
            {
                OnEnemyHealthChanged(enemyHealth.CurrentHealth, enemyHealth.MaxHealth);
            }

            if (playerStamina != null)
            {
                OnStaminaChanged(playerStamina.CurrentStamina, playerStamina.MaxStamina);
            }
        }

        private void OnPlayerHealthChanged(float current, float max)
        {
            SetText(playerHealthText, $"Player HP: {Mathf.CeilToInt(current)} / {Mathf.CeilToInt(max)}");
        }

        private void OnEnemyHealthChanged(float current, float max)
        {
            SetText(enemyHealthText, $"Enemy HP: {Mathf.CeilToInt(current)} / {Mathf.CeilToInt(max)}");
        }

        private void OnStaminaChanged(float current, float max)
        {
            SetText(staminaText, $"Stamina: {Mathf.CeilToInt(current)} / {Mathf.CeilToInt(max)}");
        }

        private static void SetText(Text text, string value)
        {
            if (text != null)
            {
                text.text = value;
            }
        }
    }
}


