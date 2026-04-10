using System;
using System.IO;
using UnityEngine;

#if UNITY_EDITOR
public class Screenshot : MonoBehaviour
{
  public bool captureOnStart = false;
  public string identifier = "capture";
  public string outputDir = "Assets/Screenshots";

  private void Start()
  {
    if (captureOnStart) TakeScreenshot();
  }

  public void TakeScreenshot()
  {
    // name
    string filename = $"{outputDir}/capture_{identifier}.png";
    // DateTime.Now.ToString("yyyy-MM-dd_HH-mm-ss-fff")
    if (!Directory.Exists(outputDir))
    {
      Directory.CreateDirectory(outputDir);
    }

    // take image
    Camera myCamera = GetComponent<Camera>();
    if (myCamera)
    {
      CaptureSaveTransparent(myCamera, 4096, 4096, filename);
    }
    else
    {
      Debug.LogError("Camera component not found! Please add one.");
    }
  }

  // based on https://stackoverflow.com/a/64552656
  public static void CaptureSaveTransparent(Camera cam, int width, int height, string savePath)
  {
    // Depending on your render pipeline, this may not work.
    var bak_cam_targetTexture = cam.targetTexture;
    var bak_cam_clearFlags = cam.clearFlags;
    var bak_RenderTexture_active = RenderTexture.active;

    var tex_transparent = new Texture2D(width, height, TextureFormat.ARGB32, false);
    // Must use 24-bit depth buffer to be able to fill background.
    var render_texture = RenderTexture.GetTemporary(width, height, 24, RenderTextureFormat.ARGB32);
    var grab_area = new Rect(0, 0, width, height);

    RenderTexture.active = render_texture;
    cam.targetTexture = render_texture;
    cam.clearFlags = CameraClearFlags.SolidColor;

    // Simple: use a clear background
    cam.backgroundColor = Color.clear;
    cam.Render();
    tex_transparent.ReadPixels(grab_area, 0, 0);
    tex_transparent.Apply();

    // Encode the resulting output texture to a byte array then write to the file
    byte[] pngShot = ImageConversion.EncodeToPNG(tex_transparent);
    File.WriteAllBytes(savePath, pngShot);

    cam.clearFlags = bak_cam_clearFlags;
    cam.targetTexture = bak_cam_targetTexture;
    RenderTexture.active = bak_RenderTexture_active;
    RenderTexture.ReleaseTemporary(render_texture);
    Texture2D.DestroyImmediate(tex_transparent);

    Debug.Log($"Captured {savePath}");
  }

}
#endif
