using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour
{
    Animator animator;
    SpriteRenderer sprite;
    GameObject bulletBill;
    Rigidbody2D rb;


    void Start()
    {
        animator = GetComponent<Animator>();
        sprite = GetComponent<SpriteRenderer>();
        rb = GetComponent<Rigidbody2D>();
        GameObject bulletBill = GameObject.Find("BulletBill");
    }


    void Update()
    {
        Destroy(gameObject, 18);
    }


    public void Death()
    {
        if (bulletBill != null)
        {
            BulletBill billScript = bulletBill.GetComponent<BulletBill>();

            if (billScript != null)
            {
                billScript.bulletSpeed = 0;
            }

        }
        rb.velocity = new Vector2(0,-6.5f);
        

        sprite.flipY = true;
        animator.SetTrigger("Death");
        Destroy(gameObject.GetComponent<BoxCollider2D>());
        Destroy(transform.root.gameObject, 4.5f);
    }
}
