// Normal Mapping for a Triplanar Shader - Ben Golus 2017
// edit by cubee. added some more textures and removed normal maps.
// i get that's besides the point but i'm lazy so i'm wrangling this one to my needs
// Unity Surface Shader example shader

Shader "Triplanar/Simple Lit" {
  Properties {
    _MainTex("Texture (Floor)", 2D) = "white" {}
    _Color("Floor Tint", Color) = (1,1,1,1)
    _MainTexW("Texture (Walls)", 2D) = "white" {}
    _ColorW("Walls Tint", Color) = (1,1,1,1)
    _MainTexC("Texture (Ceiling)", 2D) = "white" {}
    _ColorC("Ceiling Tint", Color) = (1,1,1,1)
    [Toggle] _LocalSpace("Use Object Local Position", Float) = 0
    _Glossiness("Smoothness", Range(0, 1)) = 0.5
    [Gamma] _Metallic("Metallic", Range(0, 1)) = 0
  }
  SubShader {
    Tags { "RenderType"="Opaque" }
    LOD 200

    CGPROGRAM
    // Physically based Standard lighting model, and enable shadows on all light types
    #pragma surface surf Standard fullforwardshadows

    // Use shader model 3.0 target, to get nicer looking lighting
    #pragma target 3.0

    #include "UnityStandardUtils.cginc"


    // flip UVs horizontally to correct for back side projection
    #define TRIPLANAR_CORRECT_PROJECTED_U

    sampler2D _MainTex;
    sampler2D _MainTexW;
    sampler2D _MainTexC;
    float4 _MainTex_ST;
    float4 _MainTexW_ST;
    float4 _MainTexC_ST;
    float4 _Color;
    float4 _ColorW;
    float4 _ColorC;

    half _Glossiness;
    half _Metallic;

    float _LocalSpace;

    struct Input {
      float3 worldPos;
      float3 worldNormal;
      INTERNAL_DATA
    };

    void surf (Input IN, inout SurfaceOutputStandard o) {
      // work around bug where IN.worldNormal is always (0,0,0)!
      IN.worldNormal = WorldNormalVector(IN, float3(0,0,1));
      if (_LocalSpace) IN.worldPos -= mul(unity_ObjectToWorld, float4(0,0,0,1)).xyz;

      // calculate triplanar blend
      half3 triblend = saturate(pow(IN.worldNormal, 10));
      triblend /= max(dot(triblend, half3(1,1,1)), 0.0001);

      // minor optimization of sign(). prevents return value of 0
      half3 axisSign = IN.worldNormal < 0 ? -1 : 1;

      // calculate triplanar uvs
      // applying texture scale and offset values ala TRANSFORM_TEX macro
      float2 uvY = IN.worldPos.xz * (axisSign.y > 0 ? _MainTex_ST.xy + _MainTex_ST.zy : _MainTexC_ST.xy + _MainTexC_ST.zy);
      float2 uvX = IN.worldPos.zy * _MainTexW_ST.xy + _MainTexW_ST.zy;
      float2 uvZ = IN.worldPos.xy * _MainTexW_ST.xy + _MainTexW_ST.zy;

      // flip UVs horizontally to correct for back side projection
      uvX.x *= axisSign.x;
      uvY.x *= axisSign.y;
      uvZ.x *= -axisSign.z;

      // albedo textures
      fixed4 colY = axisSign.y > 0 ? tex2D(_MainTex, uvY) * _Color // floor
        : tex2D(_MainTexC, uvY) * _ColorC; // ceiling
      fixed4 colX = tex2D(_MainTexW, uvX) * _ColorW; // wall
      fixed4 colZ = tex2D(_MainTexW, uvZ) * _ColorW; // wall
      fixed4 col = colX * triblend.x + colY * triblend.y + colZ * triblend.z;

      half3 absVertNormal = abs(IN.worldNormal);

      // set surface ouput properties
      o.Albedo = col.rgb;
      o.Metallic = _Metallic;
      o.Smoothness = _Glossiness;

      // convert world space normals into tangent normals
      float3 t2w0 = WorldNormalVector(IN, float3(1,0,0));
      float3 t2w1 = WorldNormalVector(IN, float3(0,1,0));
      float3 t2w2 = WorldNormalVector(IN, float3(0,0,1));
      o.Normal = normalize(mul(float3x3(t2w0, t2w1, t2w2), IN.worldNormal));
    }
    ENDCG
  }
  FallBack "Diffuse"
}
