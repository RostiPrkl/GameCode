using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public bool canMove {get; private set;} = true;
    bool isSprinting => canSprint && Input.GetKey(sprintKey);
    bool shouldJump => Input.GetKeyDown(jumpKey) && characterController.isGrounded;
    bool shouldCrouch => Input.GetKeyDown(crouchKey) && !duringCrouch;

    [Header("Functional Options")]
    [SerializeField] bool canSprint = true;
    [SerializeField] KeyCode sprintKey = KeyCode.LeftShift;
    [SerializeField] bool canJump = true;
    [SerializeField] KeyCode jumpKey = KeyCode.Space;
    [SerializeField] bool cancrouch = true;
    [SerializeField] KeyCode crouchKey = KeyCode.LeftControl;
    [SerializeField] bool canUseHeadBob = true;


    [Header("Movement Params")]
    [SerializeField] float walkSpeed = 3f;
    [SerializeField] float sprintSpeed = 5f;
    [SerializeField] float crouchSpeed = 1f;
    

    [Header("Look Params")]
    [SerializeField, Range(1f, 10f)] float lookSpeedX = 2f;
    [SerializeField, Range(0f, 10f)] float lookSpeedY = 2f;
    [SerializeField, Range(1f, 180f)] float upperLookLimit = 80f;
    [SerializeField, Range(1f, 180f)] float lowerLookLimit = 80f;

    [Header("Jump Params")]
    [SerializeField] float jumpForce = 8f;
    [SerializeField] float gravity = 30f;


    [Header("Crouch Params")]
    [SerializeField] float crouchHeight = 0.35f;
    [SerializeField] float standHeight = 1.2f;
    [SerializeField] float timeToCrouch = 0.35f;
    [SerializeField] Vector3 crouchCenter = new Vector3(0, 0.5f, 0);
    [SerializeField] Vector3 standCenter = new Vector3(0, 0, 0);
    [SerializeField] float roofCheck = 0.3f;
    bool isCrouching = false;
    bool duringCrouch = false;


    [Header("HeadBob Params")]
    [SerializeField] float walkBobSpeed = 14f;
    [SerializeField] float walkBobAmount = 0.05f;
    [SerializeField] float sprintBobSpeed = 20f;
    [SerializeField] float sprintBobAmount = 0.08f;
    [SerializeField] float crouchBobSpeed = 8f;
    [SerializeField] float crouchBobAmount = 0.07f;
    float defaultYPos = 0;
    float timer;


    Camera playercamera;
    CharacterController characterController;

    Vector3 moveDirection;
    Vector2 currentInpurt;

    float rotationX = 8f;


    void Awake()
    {
        playercamera = GetComponentInChildren<Camera>();
        characterController = GetComponent<CharacterController>();
        defaultYPos = playercamera.transform.localPosition.y;

        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }


    void Update()
    {
        if(canMove)
        {
            HandleMOuseLook();
            HandleMovementInput();

            if(canJump)
                HandleJump();
            if(cancrouch)
                HandleCrouch();
            
            if(canUseHeadBob)
                HandleHeadBob();

            ApplyFinalMovement();
        }
    }


    void HandleMovementInput()
    {
        currentInpurt = new Vector2((isCrouching ? crouchSpeed : isSprinting ? sprintSpeed : walkSpeed) * Input.GetAxis("Vertical"), 
        (isCrouching ? crouchSpeed : isSprinting ? sprintSpeed : walkSpeed) * Input.GetAxis("Horizontal"));
        float moveDirectionY = moveDirection.y;
        float moveDirectionX = moveDirection.x;
        moveDirection = (transform.TransformDirection(Vector3.forward) * currentInpurt.x) +
        (transform.TransformDirection(Vector3.right) * currentInpurt.y);
        moveDirection.y = moveDirectionY;
        //moveDirectionX = moveDirection.normalized * Mathf.Clamp(moveDirection.magnitude, 0, (isSprinting ? sprintSpeed : walkSpeed));
    }


    void HandleMOuseLook()
    {
        rotationX -= Input.GetAxis("Mouse Y") * lookSpeedY;
        rotationX = Mathf.Clamp(rotationX, -upperLookLimit, lowerLookLimit);
        playercamera.transform.localRotation = Quaternion.Euler(rotationX, 0, 0);
        transform.rotation *= Quaternion.Euler(0, Input.GetAxis("Mouse X") * lookSpeedX, 0);
    }


    void HandleJump()
    {
        if(shouldJump)
            moveDirection.y = jumpForce;
    }


    void HandleCrouch()
    {
        if(shouldCrouch)
            StartCoroutine(CrouchRoutine());
    }




    void HandleHeadBob()
    {
        if(!characterController.isGrounded) return;

        if(Mathf.Abs(moveDirection.x) > 0.1f || Mathf.Abs(moveDirection.z) > 0.1f)
        {
            timer += Time.deltaTime * (isCrouching ? crouchBobSpeed : isSprinting ? sprintBobSpeed : walkBobSpeed);
            playercamera.transform.localPosition = new Vector3(
                playercamera.transform.localPosition.x, defaultYPos +
                Mathf.Sin(timer) * (isCrouching ? crouchBobAmount : isSprinting ? sprintBobAmount : walkBobAmount),
                playercamera.transform.localPosition.z
            );
        }
    }


    void ApplyFinalMovement()
    {
        if(!characterController.isGrounded)
            moveDirection.y -= gravity * Time.deltaTime;
            
        if (characterController.velocity.y < -1 && characterController.isGrounded)
            moveDirection.y = 0;

        characterController.Move(moveDirection * Time.deltaTime);
    }


    IEnumerator CrouchRoutine()
    {
        if(isCrouching && Physics.Raycast(playercamera.transform.position, Vector3.up, roofCheck))
            yield break;


        duringCrouch = true;

        float timeElapsed = 0;
        float targetHeight = isCrouching ? standHeight : crouchHeight;
        float currentHeight = characterController.height;
        Vector3 targetCenter = isCrouching ? standCenter : crouchCenter;
        Vector3 currentCenter = characterController.center;

        while(timeElapsed < timeToCrouch)
        {
            characterController.height = Mathf.Lerp(currentHeight, targetHeight, timeElapsed/timeToCrouch);
            characterController.center = Vector3.Lerp(currentCenter, targetCenter, timeElapsed/timeToCrouch);
            timeElapsed += Time.deltaTime;
            yield return null;
        }

        characterController.height = targetHeight;
        characterController.center = targetCenter;

        isCrouching = !isCrouching;

        duringCrouch = false;
    }
}
