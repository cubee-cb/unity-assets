Shader "cubee/retrop8"
{
    Properties
    {
        _MainTex ("Lit Texture", 2D) = "white" {}
        _ShadeTex ("Shaded Texture", 2D) = "white" {}
        _LightingTexelSize ("Shading Texel Size", Range (0, 1024)) = 128
        _ShadeRange ("Shading Area", Range (0, 1)) = 0.25
        _DitherRange ("Dithered Area", Range (0, 1)) = 0.40
        _MinLighting ("Minimum Light Level", Range (0, 1)) = 0.0
        _AlphaCutoff ("Alpha Cutoff", Range (0, 1)) = 0.5
        _VertexSnap ("Vertex Snapping (* metre)", Range (0, 1)) = 0
    }
    SubShader
    {
        Tags {
          "RenderType" = "TransparentCutout"
          "Queue" = "AlphaTest"
        }
        LOD 100
        Cull Off

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                fixed4 diff : COLOR0;
            };

            sampler2D _MainTex;
            sampler2D _ShadeTex;
            float4 _MainTex_ST;
            float4 _ShadeTex_ST;
            float _ShadeRange;
            float _DitherRange;
            float _MinLighting;
            float _AlphaCutoff;
            float _LightingTexelSize;
            float _VertexSnap;

            // from symm super retro surface shader
            float3 SnapToTexel(float3 WorldNormal, float2 UV0, float4 TexelSize)
            {
              // 1.) Calculate how much the texture UV coords need to
              //     shift to be at the center of the nearest texel.
              float2 originalUV = UV0.xy;
              float2 centerUV = floor(originalUV * (TexelSize.zw))/TexelSize.zw + (TexelSize.xy/2.0);
              float2 dUV = (centerUV - originalUV);

              // 2b.) Calculate how much the texture coords vary over fragment space.
              //      This essentially defines a 2x2 matrix that gets
              //      texture space (UV) deltas from fragment space (ST) deltas
              // Note: I call fragment space "ST" to disambiguate from world space "XY".
              float2 dUVdS = ddx(originalUV);
              float2 dUVdT = ddy(originalUV);

              // 2c.) Invert the texture delta from fragment delta matrix
              float2x2 dSTdUV = float2x2(dUVdT[1], -dUVdT[0], -dUVdS[1], dUVdS[0])*(1.0f/(dUVdS[0]*dUVdT[1]-dUVdT[0]*dUVdS[1]));

              // 2d.) Convert the texture delta to fragment delta
              float2 dST = mul(dSTdUV, dUV);

              // 2e.) Calculate how much the world coords vary over fragment space.
              float3 dXYZdS = ddx(WorldNormal);
              float3 dXYZdT = ddy(WorldNormal);

              // 2f.) Finally, convert our fragment space delta to a world space delta
              // And be sure to clamp it in case the derivative calc went insane
              float3 dXYZ = dXYZdS * dST[0] + dXYZdT * dST[1];
              dXYZ = clamp(dXYZ, -1, 1);

              // 3a.) Transform the snapped UV back to world space
              return (WorldNormal + dXYZ);
            }
            // from symm end

            v2f vert (appdata v)
            {
                v2f o;

                // vertex snapping
                if (_VertexSnap > 0)
                {
                  float snap = 100 * (1 - _VertexSnap);
                  float4 worldPos = mul(unity_ObjectToWorld, v.vertex) * snap;
                  worldPos.x = round(worldPos.x);
                  worldPos.y = round(worldPos.y);
                  worldPos.z = round(worldPos.z);
                  v.vertex = mul(unity_WorldToObject, worldPos) / snap;
                }

                // get vertex info
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                // get vertex normal in world space
                o.normal = UnityObjectToWorldNormal(v.normal);

                // get ambient light
                o.diff = clamp(_LightColor0 + _MinLighting, 0, 1);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // based on symm super retro surface shader
                float texelInverse = (1.0 / _LightingTexelSize);
                float4 texelSize = (float4(texelInverse, texelInverse, _LightingTexelSize, _LightingTexelSize));
                float3 texelNormal = SnapToTexel(i.normal, i.uv, texelSize);
                float light = dot(texelNormal, _WorldSpaceLightPos0.xyz);
                // based on symm end

                // sample a texture, depending if lit or not
                fixed4 colLit = tex2D(_MainTex, i.uv);
                fixed4 colShaded = tex2D(_ShadeTex, i.uv);
                fixed4 col = colLit;
                if (light < _ShadeRange)
                {
                  col = colShaded;
                }
                // dither effect
                else if (light < _DitherRange)
                {
                  int x = i.uv[0] * _LightingTexelSize;
                  int y = i.uv[1] * _LightingTexelSize;
                  if (y % 2 != x % 2)
                  {
                    col = colShaded;
                  }
                }

                // discard texture pixels that are transparent enough
                clip(col.a - _AlphaCutoff);

                // apply ambient light
                col *= i.diff;

                return col;
            }
            ENDCG
        }
    }
    FallBack "MobileToon"
}
