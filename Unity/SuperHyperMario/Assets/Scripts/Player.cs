using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Player : MonoBehaviour
{
    [Header("Move Info")]
    [SerializeField] float initialMoveSpeed = 5f;
    [SerializeField] float maxMoveSpeed = 10f;
    [SerializeField] float acceleration = 2f; 
    [SerializeField] float currentMoveSpeed;
    float xInput; 
    bool facingDir = true;
    bool canMove = true;
    
    [Header("Jump Info")]
    [SerializeField] float jumpForce = 15;
    [SerializeField] float fallMultiplier = 5f;
    [SerializeField] float lowJumpMultiplier = 6;
    [SerializeField] float coyoteTime = 0.2f;
    float coyoteTimeCounter;
    
    [Header("Collision Check")]
    [SerializeField] float groundCheckRadius;
    bool isGrounded = true;
    bool groundCheck;

    Animator animator;
    Rigidbody2D rb;


    void Start()
    {
        animator = GetComponent<Animator>();   
        rb = GetComponent<Rigidbody2D>();
    }


    void Update()
    {
        if (canMove)
            xInput = Input.GetAxisRaw("Horizontal");

        Movement();
        FlipController();
        CoyoteTimer();

        if (Input.GetButtonDown("Jump"))
            Jump();
        CollisionCheck();
        if (!isGrounded)
            JumpMultiPlier();
    }


    void Movement()
    {
        
        if (rb.velocity.x != 0)
                currentMoveSpeed = Mathf.MoveTowards(currentMoveSpeed, maxMoveSpeed, acceleration * Time.deltaTime);
        else
                currentMoveSpeed = initialMoveSpeed;

        rb.velocity = new Vector2(xInput * currentMoveSpeed, rb.velocity.y);

        if (xInput == 0)
            animator.SetBool("Walk", false);
        else
            animator.SetBool("Walk", true);
    }


    void FlipController()
    {
        if (rb.velocity.x < 0 && facingDir)
            Flip();
        else if (rb.velocity.x > 0 && !facingDir)
            Flip();
    }


    void Flip()
    {
        facingDir = !facingDir;
        transform.Rotate(0,180,0);
        currentMoveSpeed = initialMoveSpeed;
    }


    void CollisionCheck()
    {
        groundCheck = Physics2D.OverlapCircle(transform.position, groundCheckRadius, LayerMask.GetMask("Ground"));
        if (groundCheck == true && (rb.velocity.y <= 0.4 && rb.velocity.y >-0.4))
        {
            isGrounded = true;
            animator.SetBool("Jump", false);
        }
        else
            isGrounded = false;
    }


    void Jump()
    {
        if (coyoteTimeCounter > 0f)
        {
            rb.velocity = new Vector2(rb.velocity.x, jumpForce);
            animator.SetBool("Jump", true);
        }
        if (Input.GetButtonUp("Jump"))
            coyoteTimeCounter = 0f;   
    }


    void JumpMultiPlier()
    {
        if (rb.velocity.y < 0f)
            rb.velocity += Vector2.up * Physics.gravity.y * (fallMultiplier - 1) * Time.deltaTime;
        else if (rb.velocity.y > 0f && !Input.GetButton("Jump"))
            rb.velocity += Vector2.up * Physics2D.gravity.y * (lowJumpMultiplier - 1) * Time.deltaTime;
    }


    void CoyoteTimer()
    {
        if (isGrounded)
            coyoteTimeCounter = coyoteTime;
        else
            coyoteTimeCounter -= Time.deltaTime;

    }


    void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(transform.position, groundCheckRadius);
    }


    private void OnCollisionEnter2D(Collision2D collision)
    {
        if (collision.gameObject.CompareTag("Goomba"))
        {
            if (transform.position.y > collision.transform.position.y + collision.transform.localScale.y / 2)
            {
                collision.gameObject.GetComponent<EnemyGoombaVariation>().Death();
                rb.velocity = new Vector2(rb.velocity.x, jumpForce * 1.5f);
            }
            else
            {
                PlayerDeath();
            }
        }

        if (collision.gameObject.CompareTag("HammerBro"))
        {
            if (transform.position.y > collision.transform.position.y)
            {
                collision.gameObject.GetComponent<HammerBro>().Death();
                rb.velocity = new Vector2(rb.velocity.x, jumpForce * 1.5f);
            }
            else
            {
                PlayerDeath();
            }
        }

        if (collision.gameObject.CompareTag("Bullet"))
        {
            if (transform.position.y > collision.transform.position.y)
            {
                if (GameObject.Find("BulletBill") != null)
                {
                    collision.gameObject.GetComponent<Bullet>().Death();
                    rb.velocity = new Vector2(rb.velocity.x, jumpForce * 2f);
                }
            }
            else
            {
                PlayerDeath();
            }
        }
    }


    private void OnTriggerEnter2D(Collider2D collision)
    {
       if (collision.gameObject.CompareTag("FallDeath") || collision.gameObject.CompareTag("Hammer"))
       {
           PlayerDeath();
       }
    }


    public void PlayerDeath()
    {
        canMove = false;
        animator.SetTrigger("Death");
        rb.velocity = new Vector2(0f, 54.0f); 
        currentMoveSpeed = 0;
        gameObject.GetComponent<CapsuleCollider2D>().enabled = false;
        StartCoroutine(RespawnAfterDelay(1f));
    }

    private IEnumerator RespawnAfterDelay(float delay)
    {
        yield return new WaitForSecondsRealtime(delay);
        gameObject.GetComponent<CapsuleCollider2D>().enabled = true;
        RespawnPlayer();
    }

    private void RespawnPlayer()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }
}
