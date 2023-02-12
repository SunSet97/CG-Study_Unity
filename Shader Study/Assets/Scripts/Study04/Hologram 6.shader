Shader "Custom/Hologram6"
{
    Properties
    {
        _BumpMap("NormalMap", 2D) = "bump" {}
        _MainTex("NoiseMap",2D)="white"{}
        _TimeSpeed("Time Speed",Range(0.1,50)) = 1
    }
        SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue"="Transparent"}
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf nolight noambient alpha:fade

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _BumpMap;
        sampler2D _MainTex;
        float _TimeSpeed;
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float3 viewDir;//���ؽ����� �ٶ󺸴� ī�޶��� ����, LightDir�� ���ؽ����� �ٶ󺸴� ������ ����
            float3 worldPos;
        };


        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
        float random(float2 input)
        {
            return frac(sin(dot(input,float2(12.9898,78.233)))*43758.5453123);
        }

        void surf(Input IN, inout SurfaceOutput o)
        {
            float2 uv=IN.uv_MainTex.xy+_Time.y;
            float noise=round(random(uv));
            // Albedo comes from a texture tinted by color
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            //o.Albedo = c.rgb;
            o.Emission = float3(0,1,0);//pow�� �� �κ��� ���̱� ���ؼ�. ������ ������ ������ ���� 3�� ����. ���� �귯���� ����� ���� �ð��� �M
            //y�ุ �ʿ��ؼ�, frac()�� ������ �Ҽ����κи� ��ȯ.
            float rim = saturate(dot(o.Normal, IN.viewDir));
            rim = (pow(1 - rim,3)+ pow(frac(IN.worldPos.g * 3 - _Time.y), 30))*noise;//3����
            o.Alpha = rim*abs(sin(_Time.y* _TimeSpeed))*abs(sin(1-(_Time.y* _TimeSpeed)));//��� ������ ����� ��ȭ��Ŵ, ����Ƣ�� ������ ��.
        }
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten) 
        {
            return float4(0, 0, 0, s.Alpha);//���ĸ� ������ �ƹ��͵� �������� ����. lambert������ �ʿ���.
        }
        ENDCG
    }
        FallBack "Transparent/Diffuse"//�׸��ڸ� �������� �ʰ� ����� �ڵ�
}
