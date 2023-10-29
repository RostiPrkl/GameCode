using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyGoombaVariation : MonoBehaviour
{
    [Header("move info")]
    [SerializeField] float moveSpeed;
    [SerializeField] int direction;
    [SerializeField] LayerMask groundLayer;
    [SerializeField] GameObject detectionPoint;
    
    Animator animator;

    // Start is called before the first frame update
    void Start()
    {
        animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        transform.Translate(moveSpeed * direction * Time.deltaTime, 0, 0);
        transform.localScale = new Vector3(direction, 1,1);
    }

    private void LateUpdate()
    {
        Debug.DrawRay(detectionPoint.transform.position, Vector2.down, Color.green);
        RaycastHit2D hit = Physics2D.Raycast(detectionPoint.transform.position, Vector2.down, 1, groundLayer);

        if (hit.collider == null)
            Direction();

        Debug.DrawRay(detectionPoint.transform.position, Vector2.right, Color.red);
        RaycastHit2D hit2 = Physics2D.Raycast(detectionPoint.transform.position, Vector2.right, 0.5f, groundLayer);

        if (hit2.collider != null)
            Direction();
    }

    void Direction()
    {
        direction *= -1;
    }

    public void Death()
    {
        animator.SetTrigger("Death");
        moveSpeed = 0;
        Destroy(gameObject.GetComponent<Rigidbody2D>());
        Destroy(gameObject.GetComponent<BoxCollider2D>());
        Destroy(transform.root.gameObject, 1.5f);
    }
}
