Shader "Custom/RimLight 01"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _RimColor("RimColor",Color) = (1,1,1,1)
        _RimPower("RimPower",Range(1,10)) = 3
        _BumpMap("Normalmap",2d) = "bump"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        float4 _RimColor;
        float _RimPower;
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float3 viewDir;//버텍스에서 바라보는 카메라의 방향, LightDir는 버텍스에서 바라보는 조명의 방향
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
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            float rim = saturate(dot(o.Normal, IN.viewDir));//-1로 넘어가는 부분을 막는 함수 쓰기
            o.Emission = pow(1-rim,_RimPower)*_RimColor.rgb;//3제곱
            o.Alpha = c.a;
        }

        ENDCG
    }
    FallBack "Diffuse"
}
