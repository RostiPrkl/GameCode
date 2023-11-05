using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor (typeof (EnemyStateMachine))]
public class FovEditor : Editor
{
    void OnSceneGUI()
    {
        EnemyStateMachine fov = (EnemyStateMachine)target;
        Handles.color = Color.white;
        Handles.DrawWireArc(fov.transform.position, Vector3.up, Vector3.forward, 360, fov.sightRadius);
        Vector3 sightAngleA = fov.DirFromAngle(-fov.sightAngle / 2, false);
        Vector3 sightAngleB = fov.DirFromAngle(fov.sightAngle / 2, false);

        Handles.DrawLine(fov.transform.position, fov.transform.position + sightAngleA * fov.sightRadius);
        Handles.DrawLine(fov.transform.position, fov.transform.position + sightAngleB * fov.sightRadius);
    }
}
