using System;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(Screenshot))]
public class ScreenshotEditor : Editor {

  public override void OnInspectorGUI() {
    //DrawDefaultInspector();

    // get our Screenshot script and add fields
    Screenshot script = (Screenshot)target;
    script.identifier = EditorGUILayout.TextField("Screenshot Name", script.identifier);
    script.captureOnStart = EditorGUILayout.Toggle("Capture on Start()", script.captureOnStart);

    // button that triggers the script to take a screenshot in-editor
    if (GUILayout.Button("Take Screenshot"))
    {
      //add everthing the button would do.
      script.TakeScreenshot();
    }

    EditorGUILayout.LabelField("This will take a 4K screenshot. It may take a moment for it to save.");


  }

}
