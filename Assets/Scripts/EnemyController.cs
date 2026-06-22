using System.Collections;
using UnityEngine;

namespace ProjectVesper.Combat
{
    [RequireComponent(typeof(CharacterController))]
    [RequireComponent(typeof(Health))]
    public sealed class EnemyController : MonoBehaviour
    {
        [SerializeField] private Transform target;
        [SerializeField] private float moveSpeed = 3.4f;
        [SerializeField] private float rotationSpeed = 12f;
        [SerializeField] private float attackRange = 1.65f;
        [SerializeField] private float attackRadius = 0.85f;
        [SerializeField] private float attackDamage = 12f;
        [SerializeField] private float attackCooldown = 1.1f;
        [SerializeField] private float attackWindup = 0.18f;
        [SerializeField] private LayerMask playerLayers;

        private CharacterController controller;
        private Health health;
        private bool isAttacking;
        private float nextAttackTime;

        private void Awake()
        {
            controller = GetComponent<CharacterController>();
            health = GetComponent<Health>();
        }

        private void Start()
        {
            if (target == null)
            {
                GameObject player = GameObject.FindGameObjectWithTag("Player");
                if (player != null)
                {
                    target = player.transform;
                }
            }
        }

        private void Update()
        {
            if (health.IsDead || target == null)
            {
                return;
            }

            Vector3 toTarget = target.position - transform.position;
            toTarget.y = 0f;

            if (toTarget.sqrMagnitude <= 0.001f)
            {
                return;
            }

            RotateToward(toTarget.normalized);

            float distance = toTarget.magnitude;
            if (distance > attackRange)
            {
                controller.SimpleMove(toTarget.normalized * moveSpeed);
                return;
            }

            TryAttack();
        }

        private void RotateToward(Vector3 direction)
        {
            Quaternion targetRotation = Quaternion.LookRotation(direction, Vector3.up);
            transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);
        }

        private void TryAttack()
        {
            if (isAttacking || Time.time < nextAttackTime)
            {
                return;
            }

            StartCoroutine(AttackRoutine());
        }

        private IEnumerator AttackRoutine()
        {
            isAttacking = true;
            nextAttackTime = Time.time + attackCooldown;
            yield return new WaitForSeconds(attackWindup);

            Vector3 center = transform.position + transform.forward * attackRange;
            Collider[] hits = Physics.OverlapSphere(center, attackRadius, playerLayers, QueryTriggerInteraction.Ignore);

            foreach (Collider hit in hits)
            {
                if (hit.TryGetComponent(out Health targetHealth))
                {
                    targetHealth.TakeDamage(attackDamage);
                }
            }

            isAttacking = false;
        }

        private void OnDrawGizmosSelected()
        {
            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(transform.position + transform.forward * attackRange, attackRadius);
        }
    }
}

