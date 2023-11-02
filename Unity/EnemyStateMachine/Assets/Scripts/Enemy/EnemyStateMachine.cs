using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class EnemyStateMachine : MonoBehaviour
{
    [Header("Eye Info")]
    public float sightRange;
    public float sightRadius;
    [Range(0,360)]
    public float sightAngle;
    public Transform eye;
    public LayerMask targetMask;
    public LayerMask obstacleMask;

    [Header("Search Info")]
    public MeshRenderer indicator;
    public float searchDuration;
    public float searchTurnSpeed;
    public Transform[] waypoints;
    public Vector3 lastKnownPlayerPosition;

    [HideInInspector] public Transform chaseTarget;
    [HideInInspector] public IEnemyState currentState;
    [HideInInspector] public EnemyPatrolState patrolState;
    [HideInInspector] public EnemyAlertState alertState;
    [HideInInspector] public EnemyChaseState chaseState;
    [HideInInspector] public EnemyTrackingState trackingState;
    [HideInInspector] public NavMeshAgent navMeshAgent;

    
    private void Awake()
    {
        navMeshAgent = GetComponent<NavMeshAgent>();
        patrolState = new EnemyPatrolState(this);
        alertState = new EnemyAlertState(this);
        chaseState = new EnemyChaseState(this);
        trackingState = new EnemyTrackingState(this);
    }


      public Vector3 DirFromAngle(float angleInDeg, bool angleIsGlobal)
    {
        if (!angleIsGlobal)
            angleInDeg += transform.eulerAngles.y;
        return new Vector3(Mathf.Sin(angleInDeg * Mathf.Deg2Rad), 0, Mathf.Cos(angleInDeg * Mathf.Deg2Rad));
    }


    void Start() => currentState = patrolState;


    void Update() => currentState.UpdateState();


    private void OnTriggerEnter(Collider other) => currentState.OnTriggerEnter(other);
}
