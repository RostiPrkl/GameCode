using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    private Rigidbody2D rb;
    private Animator anim;
    private SpriteRenderer sprite;

    [Header("Move Info")]
    [SerializeField] private float moveSpeed;
    [SerializeField] private float maxSpeed;
    [SerializeField] private float mileStoneIncreaser;
    [SerializeField] private float speedMultiplier;
    [SerializeField] private float jumpForce;
    [SerializeField] private float doubleJumpForce;
    private float defaultSpeed;
    private float speedMilestone;
    private float DefaultMilestoneIncrease;
    private bool canDoubleJump;

    [Header("Collision Info")]
    [SerializeField] private LayerMask whatIsGround;
    [SerializeField] private Transform wallCheckDistance;
    [SerializeField] private Vector2 wallCheckSize;
    [SerializeField] private float ceilingCheckDistance;
    [SerializeField] private float groundCheckDistance;
    [HideInInspector]public bool ledgeDetected;
    private bool isGrounded;
    private bool wallDetected;
    private bool ceilingDetected;

    [Header("Slide Info")]
    [SerializeField] private float slideSpeed;
    [SerializeField] private float slideTime;
    [SerializeField] private float slideCooldown;
    private float slideCooldownCounter;
    private float slideTimeCounter;
    private bool isSliding;

    [Header("Ledge Info")]
    [SerializeField] private Vector2 offsetClimb;
    [SerializeField] private Vector2 offsetClimbOver;
    private Vector2 ClimbBegunPosition;
    private Vector2 ClimbOverPosition;
    private bool canGrabLedge = true;
    private bool canClimb;

    [Header("KnockBack Info")]
    [SerializeField] private Vector2 KnockBackDir;
    private bool canBeKnocked = true;
    private bool isKnocked;

    private bool playerUnlocked;
    private bool isDead;

    void Start()
    {
        playerUnlocked = false;

        rb = GetComponent<Rigidbody2D>();
        anim = GetComponent<Animator>();
        sprite = GetComponent<SpriteRenderer>();

        speedMilestone = mileStoneIncreaser;
        defaultSpeed = moveSpeed;
        DefaultMilestoneIncrease = mileStoneIncreaser;
    }

    void Update()
    {
        CheckCollision();
        AnimatorControllers();

        slideCooldownCounter -= Time.deltaTime;

        if(isKnocked)
            return;

        if(isDead)
            return;

        if(playerUnlocked)
            Movement();

        if(isGrounded)
            canDoubleJump = true;

        CheckForLedge();
        SpeedContoller();
        CheckInput();
        CheckForSlide();


        if(Input.GetKeyDown(KeyCode.K))
            KnockBack();
        
        if(Input.GetKeyDown(KeyCode.O) && !isDead)
            StartCoroutine(Die());
    }

    private IEnumerator Invincibility()
    {
        Color originalColor = sprite.color;
        Color darkenColor = new Color(sprite.color.r, sprite.color.g, sprite.color.b, .3f);

        canBeKnocked = false;
        sprite.color = darkenColor;
        yield return new WaitForSeconds(.2f);
        sprite.color = originalColor;
        yield return new WaitForSeconds(.2f);
        sprite.color = darkenColor;
        yield return new WaitForSeconds(.2f);
        sprite.color = originalColor;
        yield return new WaitForSeconds(.3f);
        sprite.color = darkenColor;
        yield return new WaitForSeconds(.3f);
        sprite.color = originalColor;
        canBeKnocked = true;
    }

    private IEnumerator Die()
    {
        isDead = true;
        rb.velocity = KnockBackDir;
        anim.SetBool("isDead", true);

        yield return new WaitForSeconds(.5f);
        rb.velocity = new Vector2(0, 0);
        yield return new WaitForSeconds(1f);
        GameManager.instance.RestartLevel();
    }

    private void Movement()
    {
        if(wallDetected)
        {
            SpeedReset();
            return;
        }
        if(isSliding)
            rb.velocity = new Vector2(slideSpeed, rb.velocity.y);
        else
            rb.velocity = new Vector2(moveSpeed, rb.velocity.y);
    }

    private void CheckInput()
    {
        if(Input.GetButton("Fire1"))
            playerUnlocked = true;         

        if(Input.GetButtonDown("Jump"))
            JumpButton();

        if(Input.GetKeyDown(KeyCode.LeftShift))
            SlideButton();
    }

    private void SlideButton()
    {
        if(rb.velocity.x != 0 && slideCooldownCounter < 0)
        {
            isSliding = true;
            slideTimeCounter = slideTime;
            slideCooldownCounter = slideCooldown;
        }
    }

    private void JumpButton()
    {
        if(isSliding)
            return;

        if(isGrounded)
        {
            rb.velocity = new Vector2(rb.velocity.x, jumpForce);
        }
        else if(canDoubleJump)
        {
            canDoubleJump = false;
            rb.velocity = new Vector2(rb.velocity.x, doubleJumpForce);
        }
    }

    private void KnockBack()
    {
        if(!canBeKnocked)
            return;
        StartCoroutine(Invincibility());

        isKnocked = true;
        rb.velocity = KnockBackDir;
        SpeedReset();
    }

    public void Damage()
    {
        if(moveSpeed >= maxSpeed / 5f)
            KnockBack();
        else
            StartCoroutine(Die());
    }

    private void SpeedReset()
    {
        moveSpeed = defaultSpeed;
        mileStoneIncreaser = DefaultMilestoneIncrease;
    }

    private void SpeedContoller()
    {
        if(moveSpeed == maxSpeed)
            return;

        if(transform.position.x > speedMilestone)
        {
            speedMilestone = speedMilestone + mileStoneIncreaser;

            moveSpeed = moveSpeed * speedMultiplier;
            mileStoneIncreaser = mileStoneIncreaser * speedMultiplier;

            if(moveSpeed > maxSpeed)
                moveSpeed = maxSpeed;
        }
    }

    private void CheckForSlide()
    {
        if (isSliding)
        {
            slideTimeCounter -= Time.deltaTime;
            if (slideTimeCounter < 0 && !ceilingDetected)
                {
                    isSliding = false;
                }
        }
    }

    private void CheckForLedge()
    {
        if(ledgeDetected && canGrabLedge)
        {
            canGrabLedge = false;
            rb.gravityScale = 0;
            Vector2 ledgePosition = GetComponentInChildren<LedgeDetection>().transform.position;
            ClimbBegunPosition = ledgePosition + offsetClimb;
            ClimbOverPosition = ledgePosition + offsetClimbOver;
            canClimb = true;
        }

        if(canClimb)
            transform.position = ClimbBegunPosition;
    }

    private void LedgeClimbOver()
    {
        canClimb = false;
        rb.gravityScale = 5;
        transform.position = ClimbOverPosition;
        Invoke("AllowLedgeGrab", .1f);
    }

    private void AllowLedgeGrab() => canGrabLedge = true;

    private void RollAnimFinished() => anim.SetBool("canRoll", false);

    private void CancelKnockBack() => isKnocked = false;

    private void CheckCollision()
    {
        isGrounded = Physics2D.Raycast(transform.position, Vector2.down, groundCheckDistance, whatIsGround);
        ceilingDetected = Physics2D.Raycast(transform.position, Vector2.up, ceilingCheckDistance, whatIsGround);
        wallDetected = Physics2D.BoxCast(wallCheckDistance.position, wallCheckSize, 0, Vector2.zero, 0, whatIsGround);
    }

    private void OnDrawGizmos() 
    {
        Gizmos.DrawLine(transform.position, new Vector2(transform.position.x, transform.position.y - groundCheckDistance));
        Gizmos.DrawLine(transform.position, new Vector2(transform.position.x, transform.position.y + ceilingCheckDistance));
        Gizmos.DrawWireCube(wallCheckDistance.position, wallCheckSize);
    }

    private void AnimatorControllers()
    {
        anim.SetBool("isGrounded", isGrounded);
        anim.SetBool("canDoubleJump", canDoubleJump);
        anim.SetBool("isSliding", isSliding);
        anim.SetBool("canClimb", canClimb);
        anim.SetBool("isKnocked", isKnocked);
        anim.SetFloat("xVelocity", rb.velocity.x);
        anim.SetFloat("yVelocity", rb.velocity.y);

        if(rb.velocity.y < -20)
            anim.SetBool("canRoll", true);
    }
}
