using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyAlertState : IEnemyState
{
    private EnemyStateMachine enemy;
    float searchTimer;


    public EnemyAlertState(EnemyStateMachine enemystateMachine) => enemy = enemystateMachine;


    public void UpdateState()
    {
        Search();
        Look();
    }


    public void OnTriggerEnter(Collider other)
    {

    }

    public void ToPatrolState()
    {
        searchTimer = 0;
        enemy.currentState = enemy.patrolState;
    }


    public void ToAlertState()
    {

    }


    public void ToChaseState()
    {
        searchTimer = 0;
        enemy.currentState = enemy.chaseState;
    }


    public void ToTrackingState() => enemy.currentState = enemy.trackingState;


    void Search()
    {
        enemy.indicator.material.color = Color.yellow;
        enemy.navMeshAgent.isStopped = true;
        enemy.transform.Rotate(0, enemy.searchTurnSpeed * Time.deltaTime, 0);
        searchTimer += Time.deltaTime;
        if (searchTimer >= enemy.searchDuration)
            ToPatrolState();
    }


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
                        ToChaseState();
                    }
                }
            }
        }
    }
}
