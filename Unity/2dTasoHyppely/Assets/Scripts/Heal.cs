using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Heal : MonoBehaviour
{
    [Header("Heal Info")]
    [SerializeField] private float addMaxHeal = 15;
    [SerializeField] private float healAmount = 15;

    [Header("Move Info")]
    [SerializeField] private float rotationspeed;
    [SerializeField] private float speed;
    [SerializeField] private Transform[] movePoint;

    private int i;
    
    
    void Start()
    {
        transform.position = movePoint[0].position;
    }


    void Update()
    {
        transform.position = Vector3.MoveTowards(transform.position, movePoint[i].position, speed * Time.deltaTime);

        if (Vector2.Distance(transform.position, movePoint[i].position) < .25f)
        {
            i++;

            if (i >= movePoint.Length)
                i = 0;
        }

        if (transform.position.x > movePoint[i].position.x)
            transform.Rotate(new Vector3(0, 0, rotationspeed * Time.deltaTime));
        else
            transform.Rotate(new Vector3(0, 0, -rotationspeed * Time.deltaTime));

    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        AddHealth(collision);
        AddMaxHealth(collision);
    }

    private void AddHealth(Collider2D collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            PlayerController player = collision.gameObject.GetComponent<PlayerController>();

            player.health += healAmount;

            if (player.health >= player.maxHealth)
                player.health = player.maxHealth;

            Destroy(transform.root.gameObject);
        }
    }

    private void AddMaxHealth(Collider2D collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            PlayerController player = collision.gameObject.GetComponent<PlayerController>();
            player.maxHealth += addMaxHeal;

            player.health = player.maxHealth;
            Destroy(transform.root.gameObject);
        }
    }
}