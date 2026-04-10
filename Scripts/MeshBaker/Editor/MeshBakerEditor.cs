using System;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(MeshBaker))]
public class MeshBakerEditor : Editor {

  public override void OnInspectorGUI() {
    //DrawDefaultInspector();

    EditorGUILayout.LabelField("Current Limitations: Only handles one Material Slot per mesh.");

    // get our Screenshot script and add fields
    MeshBaker script = (MeshBaker)target;
    script.identifier = EditorGUILayout.TextField("Mesh Name", script.identifier);
    script.matchScale = EditorGUILayout.Toggle("Apply Scale from Transform Component", script.matchScale);

    // button that triggers the script to take a screenshot in-editor
    if (GUILayout.Button("Bake to static Mesh"))
    {
      // add everthing the button would do.
      script.BakeParent();
    }

    EditorGUILayout.LabelField("This will bake the Skinned Mesh to a regular mesh. It may take a moment for it to save.");


  }

}
