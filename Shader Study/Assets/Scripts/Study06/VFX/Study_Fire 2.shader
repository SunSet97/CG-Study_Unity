Shader "Custom/study06_fire_VFX"
{
    Properties
    {
        _TintColor("Tint Color",Color)=(0.5,0.5,0.5,0.5)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _MainTex2 ("Albedo (RGB)", 2D) = "white" {}
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("SrcBlend Mode",Float)=5
        [Enum(UnityEngine.Rendering.BlendMode)]_DstcBlend("DstBlend Mode",Float)=10

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" }
        zwrite off 
        Blend [_SrcBlend] [_DstcBlend]
        cull off
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf nolight keepalpha noforwardadd nolightmap noambient novertexlights noshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _MainTex2;
        float4 _TintColor;
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_MainTex2;
            float4 color:COLOR;
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
            c=c*2*_TintColor*IN.color;
            fixed4 d = tex2D (_MainTex2, float2(IN.uv_MainTex2.x,IN.uv_MainTex2.y-_Time.y));
            o.Emission=c.rgb*d.rgb;     //emission으로 하면 빛의 영향을 안받게 됨       
    
            o.Alpha = c.a*d.a;
        }
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten)
        {
            return float4(0,0,0,s.Alpha);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
