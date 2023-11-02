using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyPatrolState : IEnemyState
{
 
    private EnemyStateMachine enemy;
    int nextWaypoint;

    public EnemyPatrolState(EnemyStateMachine enemystateMachine) => enemy = enemystateMachine;

    public void UpdateState()
    {
        Patrol();
        Look();
    }


    public void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
            ToAlertState();

    }


    public void ToPatrolState()
    {
        
    }


    public void ToAlertState() => enemy.currentState = enemy.alertState;


    public void ToChaseState() => enemy.currentState = enemy.chaseState;


    public void ToTrackingState() => enemy.currentState = enemy.trackingState;



    void Look()
{
    Collider[] targetsInViewRadius = Physics.OverlapSphere(enemy.transform.position, enemy.sightRadius, enemy.targetMask);

    for (int i = 0; i < targetsInViewRadius.Length; i++)
    {
        if (targetsInViewRadius[i].CompareTag("Player"))
        {
            Transform target = targetsInViewRadius[i].transform;
            Vector3 dirToTarget = (target.position - enemy.transform.position).normalized;
            if (Vector3.Angle(enemy.transform.forward, dirToTarget) < enemy.sightAngle)
            {
                float dstToTarget = Vector3.Distance(enemy.transform.position, target.position);
                if (!Physics.Raycast(enemy.transform.position, dirToTarget, dstToTarget, enemy.obstacleMask))
                {
                    enemy.chaseTarget = target;
                    ToAlertState();
                }
            }
        }
    }
}


    void Patrol()
    {
        enemy.indicator.material.color = Color.green;
        enemy.navMeshAgent.destination = enemy.waypoints[nextWaypoint].position;
        enemy.navMeshAgent.isStopped = false;

        if(enemy.navMeshAgent.remainingDistance <= enemy.navMeshAgent.stoppingDistance && !enemy.navMeshAgent.pathPending)
        {
            nextWaypoint = (nextWaypoint + 1) % enemy.waypoints.Length;
        }
        
    }
}
