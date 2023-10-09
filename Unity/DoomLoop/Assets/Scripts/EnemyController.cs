using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyController : MonoBehaviour
{
    [SerializeField] int health;
    [SerializeField] GameObject explosion;
    [SerializeField] float PlayerRange = 10f;
    [SerializeField] Rigidbody2D rb;
    [SerializeField] float enemySpeed = 2;
    

    void Start()
    {
        
    }


    void Update()
    {
        if (Vector3.Distance(transform.position, PlayerController.instance.transform.position)< PlayerRange)
        {
            Vector3 playerDirection = PlayerController.instance.transform.position - transform.position;
            rb.velocity = playerDirection.normalized * enemySpeed;
        }
        else
        {
            rb.velocity = Vector2.zero;
        }
    }


    public void TakeDamage()
    {
        health--;
        if (health <= 0)
        {
            Instantiate(explosion, transform.position, transform.rotation);
            Destroy(gameObject);
        }
    }
}
