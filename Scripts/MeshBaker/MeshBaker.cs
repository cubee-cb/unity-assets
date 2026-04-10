using System;
using System.IO;
using UnityEngine;
using UnityEditor;

public class MeshBaker : MonoBehaviour
{
  public bool matchScale = false;
  public string identifier = "skinnedmesh";
  public string outputDir = "Assets/BakedMeshes";

  // Start is called before the first frame update
  void Start()
  {

  }

  public void BakeParent()
  {
    // name
    string filename = $"{outputDir}/mesh_{identifier}_baked.asset";
    // DateTime.Now.ToString("yyyy-MM-dd_HH-mm-ss-fff")
    if (!Directory.Exists(outputDir))
    {
      Directory.CreateDirectory(outputDir);
    }

    // get meshes
    SkinnedMeshRenderer[] skinnedMeshes = GetComponentsInChildren<SkinnedMeshRenderer>();
    MeshFilter[] meshFilters = GetComponentsInChildren<MeshFilter>();
    CombineInstance[] combineInstances = new CombineInstance[skinnedMeshes.Length + meshFilters.Length];

    // bake mesh
    int index = 0;
    if (combineInstances.Length > 0)
    {
      // add static meshes to the queue
      print("meshes to process: " + meshFilters.Length);
      foreach (MeshFilter f in meshFilters)
      {
        combineInstances[index] = new CombineInstance
        {
          mesh = f.mesh,
          transform = f.transform.localToWorldMatrix,
        };

        index++;
      }

      // bake skinned meshes to normal meshes, then add them to the queue
      print("skinned meshes to process: " + meshFilters.Length);
      foreach (SkinnedMeshRenderer s in skinnedMeshes)
      {
        Mesh bakedMesh = new Mesh();
        s.BakeMesh(bakedMesh, matchScale);

        combineInstances[index] = new CombineInstance
        {
          mesh = bakedMesh,
          transform = s.transform.localToWorldMatrix,
        };

        index++;
      }

      // combine the meshes
      print("combining meshes...");
      Mesh outputMesh = new Mesh();
      outputMesh.CombineMeshes(combineInstances, false);

      // save Mesh asset
      AssetDatabase.CreateAsset(outputMesh, filename);
      AssetDatabase.SaveAssets();
      print("wrote combined mesh to file! see: " + outputDir);
    }
    else
    {
      Debug.LogError("No MeshRenderer nor SkinnedMeshRenderer components found! Please add at least one.");
    }
  }

}
