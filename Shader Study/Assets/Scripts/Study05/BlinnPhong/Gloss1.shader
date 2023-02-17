Shader "Custom/Gloss1"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("NormalMap",2D)="bump"{}
        _SpecCol ("Specular Color",Color)=(1,1,1,1)
        _SpecPow ("Specular Power",Range(10,200))=100
        _GlossTex ("Gloss Tex",2D)="white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Test

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _GlossTex;
        float4 _SpecCol;
        float _SpecPow;
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float2 uv_GlossTex;
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
            float4 m = tex2D (_GlossTex,IN.uv_GlossTex);
            o.Albedo = c.rgb;
            o.Normal=UnpackNormal(tex2D(_BumpMap,IN.uv_BumpMap));
            o.Gloss=m.a;
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
            float3 SpecColor;
            float3 H=normalize(lightDir+viewDir);//두 벡터를 더해서 가운데 벡터를 만들고 이를 노말라이즈 해서 1로 만듦.
            float spec=saturate(dot(H,s.Normal));
            spec=pow(spec,_SpecPow);
            SpecColor=spec*_SpecCol.rgb*s.Gloss;
            //final term
            final.rgb=DiffColor.rgb+SpecColor;
            final.a=s.Alpha;
            return final;
            
        }

        ENDCG
    }
    FallBack "Diffuse"
}
