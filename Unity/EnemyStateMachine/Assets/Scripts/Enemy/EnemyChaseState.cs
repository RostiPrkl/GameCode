using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class EnemyChaseState : IEnemyState
{
    private EnemyStateMachine enemy;

    public EnemyChaseState(EnemyStateMachine enemystateMachine) => enemy = enemystateMachine;

    public void UpdateState()
    {
        Chase();
        Look();
    }


    public void OnTriggerEnter(Collider other)
    {

    }


    public void ToPatrolState() => enemy.currentState = enemy.patrolState;


    public void ToAlertState() => enemy.currentState = enemy.alertState;


    public void ToTrackingState() => enemy.currentState = enemy.trackingState;


    public void ToChaseState()    
    {

    }


    void Chase()

    {
        enemy.indicator.material.color = Color.red;
        enemy.navMeshAgent.destination = enemy.chaseTarget.position;
        enemy.navMeshAgent.isStopped = false;
    }


    void Look()
    {
        Vector3 enemyToTarget = enemy.chaseTarget.position - enemy.eye.position;

        Debug.DrawRay(enemy.eye.position, enemyToTarget, Color.red);
        RaycastHit hit;
        if(Physics.Raycast(enemy.eye.position, enemyToTarget, out hit, enemy.sightRange) && hit.collider.CompareTag("Player"))
            enemy.chaseTarget = hit.transform;
        else
        {
            enemy.lastKnownPlayerPosition = enemy.chaseTarget.position + new Vector3(0, 0, 5);
            ToTrackingState();
        }
    }

}
