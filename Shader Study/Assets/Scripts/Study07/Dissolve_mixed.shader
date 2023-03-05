Shader "Custom/Dissolve_mixed"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Normalmap",2D) = "bump"{}
        _NoiseTex ("Noise",2D) = "white" {}
        _NoiseTex2 ("Noise2",2D) = "white" {}
        _MaskTex ("Mask",2D) = "white" {}
        _RampTex ("Ramp",2D) = "white" {}
        _Cut ("Alpha Cut", Range(0,1)) = 0
        [HDR] _OutColor1("OutColor1", Color)=(1,1,1,1)
        [HDR] _OutColor2("OutColor2", Color)=(1,1,1,1)
        _OutThickness ("_OutThickness", Range(1,1.5))=1.15
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf StandardSpecular alpha:fade

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _NoiseTex;
        sampler2D _NoiseTex2;
        sampler2D _MaskTex;
        sampler2D _RampTex;
        float _Cut;
        float4 _OutColor1;
        float4 _OutColor2;
        float _OutThickness;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float2 uv_NoiseTex;
            float2 uv_NoiseTex2;
            float2 uv_MaskTex;
            float2 uv_RampTex;
        };

        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandardSpecular o)
        {
            // Albedo comes from a texture tinted by color
            o.Normal=UnpackNormal(tex2D(_BumpMap,IN.uv_BumpMap));
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            float4 noise=tex2D(_NoiseTex,IN.uv_NoiseTex);
            float4 noise2=tex2D(_NoiseTex2,IN.uv_NoiseTex2);
            float4 m = tex2D (_MaskTex, IN.uv_MaskTex);
            float4 Ramp=tex2D(_RampTex, float2(_Time.y,0.5));
            // _Time.y는 x축으로 계속 우측으로 움직이면서, 0.5는 y축으로 처리하는 uv를 만들어서 적용하면 이미지의 X값을 참조하는 애니메이션 생성
            o.Albedo = c.rgb;
            //o.Emission=c.rgb*m.g*Ramp.r;

            float alpha;
            if(noise.r>=_Cut)
            {
                alpha=1;
            }
            else
            {
                alpha=0;
            }
            //specular 색깔
            float outline1;
            if(noise.r>=_Cut*_OutThickness)
            {
                outline1=0;
            }
            else
            {
                outline1=1;
            }
            //emission색깔
            float outline2;
            if(noise2.r>=_Cut*_OutThickness)
            {
                outline2=0;
            }
            else
            {
                outline2=1;
            }
            fixed3 specular= outline1*_OutColor1.rgb;
            o.Specular=specular;
            o.Emission=outline2*_OutColor2.rgb+(c.rgb*m.g*Ramp.r);
            o.Alpha=alpha;
                
        }
        ENDCG
    }
    FallBack "Diffuse"
}
