Shader "Custom/Outline3"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        //cull back 뒷면을 그리지 않음. 대부분 자동으로 됨.
        cull front//면 뒤집어짐

        //1pass
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Nolight vertex:vert noshadow noambient

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0


        void vert(inout appdata_full v)
        {
            v.vertex.xyz=v.vertex.xyz+v.normal.xyz*0.01;

        }

        struct Input
        {
            float2 color:COLOR;
        };

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
           
        }
        float4 LightingNolight(SurfaceOutput s, float3 lightDir, float atten)
        {
            return float4(0,0,0,1);
        }
        ENDCG
        cull back//다시 뒤집어줌
        
        //2pass
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Toon

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        float4 LightingToon(SurfaceOutput s, float3 lightDir, float atten)
        {
            float ndotl=dot(s.Normal,lightDir)*0.5+0.5;
            /*if(ndotl>0.5)
            {
                ndotl=1;
            }
            else
            {
                ndotl=0.3;
            }*/
            ndotl=ndotl*3;
            ndotl=ceil(ndotl)/3;//ceil은 정수로 만들어 주는 함수//5단계로 나눔
            float4 final;
            final.rgb=s.Albedo*ndotl*_LightColor0.rgb;
            final.a=s.Alpha;
            return final;

        }
        ENDCG
    }
    FallBack "Diffuse"
}
