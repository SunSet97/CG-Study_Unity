Shader "Custom/Blinn_Phong1"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("NormalMap",2D)="bump"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Test noambient

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };


        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Normal=UnpackNormal(tex2D(_BumpMap,IN.uv_BumpMap));
            o.Alpha = c.a;
        }

        float4 LightingTest(SurfaceOutput s, float3 lightDir,float3 viewDir, float atten)
        {
            float4 final;
            //Lambert term
            float3 DiffColor;
            float ndotl=saturate(dot(s.Normal,lightDir));
            DiffColor=ndotl*s.Albedo*_LightColor0.rgb*atten;
            //Spec term
            float3 H=normalize(lightDir+viewDir);//두 벡터를 더해서 가운데 벡터를 만들고 이를 노말라이즈 해서 1로 만듦.
            float spec=saturate(dot(H,s.Normal));
            //final term
            final.rgb=DiffColor.rgb;
            final.a=s.Alpha;
            //return final;
            return spec;//내적연산은 -1~1까지 나오는 연산이고, 거의 양으로 90도 음으로 -90도로 180도 각도가 밝아지는것. 지금은 스펙큘러가 굉장히 넓은 것.
        }

        ENDCG
    }
    FallBack "Diffuse"
}
