using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    [Header("Move Info")]
    [SerializeField] float initialMoveSpeed = 5f;
    [SerializeField] float maxMoveSpeed = 10f;
    [SerializeField] float acceleration = 2f;
    float currentMoveSpeed; 
    
    [Header("Jump Info")]
    [SerializeField] float jumpForce = 15;
    [SerializeField] float fallMultiplier = 5f;
    [SerializeField] float lowJumpMultiplier = 6;
    bool grounded;

    Animator animator;
    Rigidbody2D rb;


    void Start()
    {
        animator = GetComponent<Animator>();   
        rb = GetComponent<Rigidbody2D>();
    }


    void Update()
    {
        GroundDetect();
        Movement();
        Jump();
    }


    void Movement()
    {
        float moveInput = Input.GetAxis("Horizontal");
    
        if (moveInput != 0)
            currentMoveSpeed = Mathf.MoveTowards(currentMoveSpeed, maxMoveSpeed, acceleration * Time.deltaTime);
        else
            currentMoveSpeed = initialMoveSpeed;

        float movement = moveInput * currentMoveSpeed * Time.deltaTime;
        transform.Translate(movement, 0, 0);

        if (Input.GetAxisRaw("Horizontal") != 0)
        {
            transform.localScale = new Vector3(Input.GetAxisRaw("Horizontal"), 1, 1);
            animator.SetBool("Walk", true);
        }
        else
            animator.SetBool("Walk", false);
    }


    void Jump()
    {
        if (Input.GetButtonDown("Jump") && grounded == true)
        {
            rb.velocity = new Vector2(rb.velocity.x, jumpForce);
            animator.SetBool("Jump", true);
        }

        if (rb.velocity.y < 0)
            rb.velocity += Vector2.up * Physics.gravity.y * (fallMultiplier - 1) * Time.deltaTime;
        else if (rb.velocity.y > 0 && !Input.GetButton("Jump"))
            rb.velocity += Vector2.up * Physics2D.gravity.y * (lowJumpMultiplier - 1) * Time.deltaTime;
    }


    void GroundDetect()
    {
        Vector3 checkPosition = transform.position;
        Vector2 boxSize = new Vector2(1.3f, 0.5f);
        RaycastHit2D casthit = Physics2D.BoxCast(checkPosition, boxSize, 0, Vector2.zero, 0, LayerMask.GetMask("Ground"));

        if (casthit == true && (rb.velocity.y <= 0.2 && rb.velocity.y >-0.2))
        {
            grounded = true;
            animator.SetBool("Jump", false);
        }
        else
            grounded = false;
            //Debug.Log(rb.velocity.y);
    }


    private void OnCollisionEnter2D(Collision2D collision)
    {
        if (collision.gameObject.CompareTag("Goomba"))
        {
            if (transform.position.y > collision.transform.position.y + collision.transform.localScale.y / 2)
            {
                collision.gameObject.GetComponent<EnemyGoombaVariation>().Death();
                rb.velocity = new Vector2(rb.velocity.x, jumpForce * 0.8f);
            }
        }
    }
}
