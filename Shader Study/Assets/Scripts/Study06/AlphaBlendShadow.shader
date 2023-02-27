Shader "Custom/AlphaBlendShadow"
{
    Properties
    {
        _Color("Main Color",Color)=(1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Cutoff("Alpha cutoff",Range(0,1))=0.5

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}        
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert alpha:fade
        //값에 따라서 그 특정값에 따라 어두운 색은 아예 찍지도 않고 밝은 색은 알파가 없는 것 처럼 그려짐.
        //알파테스트는 사실 반투명은 되지 않음. 그래서 거칠게 표현됨.
        //대신 그림자도 되고 알파소팅의 문제도 일어나지 않음, PC에서 알파 블렌딩보다 연산이 빠름.

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
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
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Legacy Shaders/Transparent/Cutout/VertexLit"
}
//불투명(Opaque)오브젝트는 먼저그린다.
//반투명(Transparent)오브젝트는 나중에 그린다.
//반투명 오브젝트끼리는 뒤에서부터 그린다.
