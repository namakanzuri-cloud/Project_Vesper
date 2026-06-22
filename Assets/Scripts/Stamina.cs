using System;
using UnityEngine;

namespace ProjectVesper.Combat
{
    public sealed class Stamina : MonoBehaviour
    {
        [SerializeField] private float maxStamina = 100f;
        [SerializeField] private float recoveryPerSecond = 28f;
        [SerializeField] private float recoveryDelay = 0.35f;

        public event Action<float, float> Changed;

        public float MaxStamina => maxStamina;
        public float CurrentStamina { get; private set; }

        private float recoveryBlockedUntil;

        private void Awake()
        {
            CurrentStamina = maxStamina;
        }

        private void Update()
        {
            if (Time.time < recoveryBlockedUntil || CurrentStamina >= maxStamina)
            {
                return;
            }

            CurrentStamina = Mathf.Min(maxStamina, CurrentStamina + recoveryPerSecond * Time.deltaTime);
            Changed?.Invoke(CurrentStamina, maxStamina);
        }

        public bool CanSpend(float amount)
        {
            return amount <= 0f || CurrentStamina >= amount;
        }

        public bool TrySpend(float amount)
        {
            if (!CanSpend(amount))
            {
                return false;
            }

            CurrentStamina = Mathf.Max(0f, CurrentStamina - amount);
            recoveryBlockedUntil = Time.time + recoveryDelay;
            Changed?.Invoke(CurrentStamina, maxStamina);
            return true;
        }
    }
}

