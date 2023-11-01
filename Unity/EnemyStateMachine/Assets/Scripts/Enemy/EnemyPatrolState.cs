using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyPatrolState : IEnemyState
{
 
    private EnemyStateMachine enemy;
    int nextWaypoint; 

    public EnemyPatrolState(EnemyStateMachine enemystateMachine)
    {
        enemy = enemystateMachine;
    }

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


    public void ToAlertState()
    {
        enemy.currentState = enemy.alertState;
    }


    public void ToChaseState()
    {

    }


    public void ToTrackingState()
    {
        enemy.currentState = enemy.trackingState;
    }
    


    void Look()
    {
        Debug.DrawRay(enemy.eye.position, enemy.eye.forward * enemy.sightRange, Color.green);
        RaycastHit hit;
        if(Physics.Raycast(enemy.eye.position, enemy.eye.forward, out hit, enemy.sightRange) && hit.collider.CompareTag("Player"))
        {
            enemy.chaseTarget = hit.transform;
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
            ToAlertState();
        }
        
    }
}
