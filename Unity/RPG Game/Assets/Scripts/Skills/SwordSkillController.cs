using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SwordSkillController : MonoBehaviour
{
    private Animator anim;
    private Rigidbody2D rb;
    private CircleCollider2D cd;
    private Player player;
    private bool canRotate = true;
    private bool isReturning;
    [SerializeField] private float returnSpeed = 17f;

    //private bool isBouncing = true;
    //private int amountOfBounce;
    //private  List<Transform> enemyTarget; <-- BUG HERE INVESTIGATE
    //private int targetIndex;
    //private float bounceSpeed;


    private void Awake() 
    {
        anim = GetComponentInChildren<Animator>();
        rb = GetComponent<Rigidbody2D>();
        cd = GetComponent<CircleCollider2D>();    
    }

    public void SetupSword(Vector2 _dir, float _gravityScale, Player _player)
    {   
        player = _player;
        rb.velocity = _dir;
        rb.gravityScale = _gravityScale;
        anim.SetBool("Rotation", true);
    }

    public void ReturnSword()
    {
        rb.constraints = RigidbodyConstraints2D.FreezeAll;
        //DEPRECATED / BUG new code above rb.isKinematic = false;
        transform.parent = null;
        isReturning = true;
    }
    
    private void Update() 
{
    if (canRotate && rb != null)
        transform.right = rb.velocity;    

    if (isReturning && player != null)
    {
        transform.position = Vector2.MoveTowards(transform.position, player.transform.position, returnSpeed * Time.deltaTime);

        if (Vector2.Distance(transform.position, player.transform.position) < 0.5)
            player.ClearTheSword();
    }

    // if (isBouncing && enemyTarget != null && targetIndex < enemyTarget.Count)
    // {
    //     if (targetIndex >= 0 && targetIndex < enemyTarget.Count)
    //     {
    //         transform.position = Vector2.MoveTowards(transform.position, enemyTarget[targetIndex].position, bounceSpeed * Time.deltaTime);

    //         if (Vector2.Distance(transform.position, enemyTarget[targetIndex].position) < .1f)
    //         {
    //             targetIndex++;
    //             amountOfBounce--;

    //             if (amountOfBounce <= 0)
    //             {
    //                 isBouncing = false;
    //                 isReturning = true;
    //             }
    //         }
    //     }
    //     else
    //     {
    //         isBouncing = false;
    //         isReturning = true;
    //     }
    // }
}

    private void OnTriggerEnter2D(Collider2D collision) 
    {
        if (collision == null || isReturning)
        return;
        
        if (isReturning)
            return;

        // if (collision.GetComponent<Enemy>() != null)
        // {
        //     Enemy enemy = collision.GetComponent<Enemy>();
        //     if (isBouncing && enemyTarget.Count <= 0)
        //     {
        //         Collider2D[] colliders = Physics2D.OverlapCircleAll(transform.position, 10);

        //         foreach (var hit in colliders)
        //         {
        //             if (hit.GetComponent<Enemy>() != null)
        //                 enemyTarget.Add(hit.transform);
        //         }
        //     }
        // }

        StuckInto(collision);

    }

    private void StuckInto(Collider2D collision)
    {   

        if (collision == null)
        return;
        
        canRotate = false;
        cd.enabled = false;

        rb.isKinematic = true;
        rb.constraints = RigidbodyConstraints2D.FreezeAll;

        // if (isBouncing && enemyTarget.Count > 0)
        //     return;

        anim.SetBool("Rotation", false);
        transform.parent = collision.transform;
    }
}
