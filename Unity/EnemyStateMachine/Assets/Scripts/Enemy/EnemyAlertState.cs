using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyAlertState : IEnemyState
{
    private EnemyStateMachine enemy;
    float searchTimer;
    

    public EnemyAlertState(EnemyStateMachine enemystateMachine)
    {
        enemy = enemystateMachine;
    }


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


    public void ToTrackingState()
    {
        //searchTimer = 0;
        enemy.currentState = enemy.trackingState;
    }


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
        Debug.DrawRay(enemy.eye.position, enemy.eye.forward * enemy.sightRange, Color.yellow);
        RaycastHit hit;
        if(Physics.Raycast(enemy.eye.position, enemy.eye.forward, out hit, enemy.sightRange) && hit.collider.CompareTag("Player"))
        {
            enemy.chaseTarget = hit.transform;
            ToChaseState();
        }
    }
}
