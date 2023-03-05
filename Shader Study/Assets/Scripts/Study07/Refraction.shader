Shader "Custom/Refraction"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _RefStrength("Reflection Strength",Range(0,0.1))=0.05
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        ZWrite off//앞의 쿼드는 다른ㅇ ㅣㄹ반 오브젝트들 보다 나중에 그려야 배경을 캡쳐가능해서 zwrite off와 Transparent계열 쉐이더를 만든다.
       
        LOD 200
        GrabPass{}

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf nolight noambient alpha:fade

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _GrabTexture;
        sampler2D _MainTex;
        float _RefStrength;

        struct Input
        {
            float4 color:COLOR;
            float4 screenPos;
            float2 uv_MainTex;
        };

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            float4 ref=tex2D(_MainTex,IN.uv_MainTex+_Time.y);
            float3 screenUV=IN.screenPos.rgb/(IN.screenPos.a+0.00001);//거리의 영향을 제거하기 위한 코드
            o.Emission=tex2D(_GrabTexture,(screenUV.xy+ref.x*_RefStrength));//실시간 캡쳐
        }
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten)
        {
            return float4(0,0,0,1);
        }
        ENDCG
    }
    FallBack "Regacy Shader/Transparent/Vertexlit"
}
