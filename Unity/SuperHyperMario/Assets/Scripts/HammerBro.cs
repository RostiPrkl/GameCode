using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HammerBro : MonoBehaviour
{
    [Header("Movement Info")]
    [SerializeField] private float speed;
    [SerializeField] private Transform[] movePoint;

    [Header("Hammer Info")]
    public GameObject hammer;
    [SerializeField] float hammerForce;
    [SerializeField] float hammerCounter;
    [SerializeField] float hammerMaxCounter;

    [Header("Jump Info")]
    [SerializeField] float jumpForce;
    [SerializeField] float jumpCounter;
    [SerializeField] float jumpMaxCounter;

    [Header("Player Info")]
    public GameObject player;
    public int direction;
    
    Animator animator;
    Rigidbody2D rb;

    private int i;


    void Start()
    {
        transform.position = movePoint[0].position;
        animator = GetComponent<Animator>();
        rb = GetComponent<Rigidbody2D>();
    }


    void Update()
    {
        if (transform.position.x < player.transform.position.x)
            transform.localScale = new Vector3(-1, 1, 1);
        else
            transform.localScale = new Vector3(1, 1, 1);

        transform.position = Vector3.MoveTowards(transform.position, movePoint[i].position, speed * Time.deltaTime);

        if (Vector2.Distance(transform.position, movePoint[i].position) < .25f)
        {
            i++;

            if (i >= movePoint.Length)
                i = 0;
        }

        if (jumpCounter > jumpMaxCounter)
        {
            jumpCounter = 0;
            jumpMaxCounter = Random.Range(0.5f, 6);
            Jump();
        }
        else
            jumpCounter += Time.deltaTime;

        if (hammerCounter > hammerMaxCounter)
        {
            hammerCounter = 0;
            hammerMaxCounter = Random.Range(1.5f, 3);
            Attack();
        }
        else
            hammerCounter += Time.deltaTime;
    }


    public void Jump()
    {
        if (rb.velocity.y == 0)
            rb.velocity = new Vector2(rb.velocity.x, jumpForce);
    }


    public void Attack()
    {
        animator.SetTrigger("Attack");
        GameObject hammerInstance = Instantiate(hammer, transform.position + new Vector3(0,1,0), Quaternion.identity);
        Vector2 throwDirection = new Vector2(hammerForce * -transform.localScale.x, hammerForce);
        hammerInstance.GetComponent<Rigidbody2D>().AddForce(throwDirection, ForceMode2D.Impulse);
        Destroy(hammerInstance, 3);
    }


    public void Death()
    {
        SpriteRenderer sprite = gameObject.GetComponent<SpriteRenderer>();
        speed = 0;
        sprite.flipY = true;
        rb.velocity = new Vector2(-1, 6);
        hammerMaxCounter = 1000;
        jumpMaxCounter = 1000;
        Destroy(gameObject.GetComponent<BoxCollider2D>());
        Destroy(transform.root.gameObject, 4.5f);
    }
}
