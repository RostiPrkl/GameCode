using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyTrackingState : IEnemyState
{
    private EnemyStateMachine enemy;
    

    public EnemyTrackingState(EnemyStateMachine enemystateMachine)
    {
        enemy = enemystateMachine;
    }


    public void UpdateState()
    {
        Look();
        Hunt();
    }


    public void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
            ToAlertState();
    }


    public void ToPatrolState()
    {
        enemy.currentState = enemy.patrolState;
    }


    public void ToAlertState()
    {
        enemy.currentState = enemy.alertState;
    }


    public void ToChaseState()
    {
        enemy.currentState = enemy.chaseState;
    }


    public void ToTrackingState()
    {
        
    }


    void Look()
    {
        Debug.DrawRay(enemy.eye.position, enemy.eye.forward * enemy.sightRange, Color.blue);
        RaycastHit hit;
        if(Physics.Raycast(enemy.eye.position, enemy.eye.forward, out hit, enemy.sightRange) && hit.collider.CompareTag("Player"))
        {
            enemy.chaseTarget = hit.transform;
            ToAlertState();
        }
    }


    void Hunt()
    {
        enemy.indicator.material.color = Color.blue;
        enemy.navMeshAgent.destination = enemy.lastKnownPlayerPosition;
        enemy.navMeshAgent.isStopped = false;

        if(enemy.navMeshAgent.remainingDistance <= enemy.navMeshAgent.stoppingDistance && !enemy.navMeshAgent.pathPending)
            ToAlertState();
    }
}
