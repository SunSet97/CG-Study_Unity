Shader "Custom/study02_fire2"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _MainTex2 ("Albedo (RGB)", 2D) = "white" {}

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard alpha:fade
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _MainTex2;
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_MainTex2;
        };

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 d = tex2D (_MainTex2, float2(IN.uv_MainTex2.x,IN.uv_MainTex2.y-_Time.y));
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex+d.r);//이미지에서 검정은 1, 흰색은 0의 값 을 가진다.
            //질문 자연스럽게 연결하게 하려면 어디에 수치를 더해야 하는가?
            o.Emission=c.rgb;     //emission으로 하면 빛의 영향을 안받게 됨       
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
