Shader "Custom/Matcap2"
{
    Properties
    {

        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Normalmap",2D) = "bump"{}
        _Matcap ("Matcap",2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf nolight noambient

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _Matcap;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float3 worldNormal;
            INTERNAL_DATA
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
            o.Normal=UnpackNormal(tex2D(_BumpMap,IN.uv_BumpMap));
            float3 worldNor = WorldNormalVector(IN,o.Normal);
            float3 viewNormal=mul((float3x3)UNITY_MATRIX_V,worldNor);//노말이 바뀜. 카메라 돌리는 것에 따라 그방향이 따라온다. view좌표계의 노말이 됨. 왼쪽은 파람.
            float2 MatcapUV=viewNormal.xy*0.5+0.5;//뒤의 연산으로 -1~1을 0~1로 만듦. 이걸 유브이로 만듦.
            o.Emission=tex2D(_Matcap,MatcapUV)*c.rgb;
            o.Alpha = c.a;
        }
        
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten)
        {
            return float4(0,0,0,s.Alpha);

        }
        ENDCG
    }
    FallBack "Diffuse"
}
