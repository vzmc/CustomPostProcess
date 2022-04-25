Shader "Hidden/Custom/Outline" 
{
    HLSLINCLUDE
    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    TEXTURE2D_SAMPLER2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture);

    inline float DecodeFloatRG(float2 enc)
    {
        float2 kDecodeDot = float2(1.0, 1 / 255.0);
        return dot(enc, kDecodeDot);
    }

    CBUFFER_START (UnityPerMaterial)
        half4 _Color;
        float _Width;
        float _DepthSensitivity;
        float _NormalSensitivity;
        float _OutlineOnly;
    CBUFFER_END

    struct Varyings 
    {
        float4 pos : SV_POSITION;
        float2 uv[5] : TEXCOORD0;
    };

    Varyings Vert(AttributesDefault v)
    {
        Varyings o;
        o.pos = float4(v.vertex.xy, 0.0, 1.0);

        float2 uv = TransformTriangleVertexToUV(v.vertex.xy);
        #if UNITY_UV_STARTS_AT_TOP
            uv = uv * float2(1.0, -1.0) + float2(0.0, 1.0);
        #endif
            
        o.uv[0] = uv;
        o.uv[1] = uv + (_ScreenParams.zw - 1) * float2(1, 1) * _Width;
        o.uv[2] = uv + (_ScreenParams.zw - 1) * float2(-1, -1) * _Width;
        o.uv[3] = uv + (_ScreenParams.zw - 1) * float2(-1, 1) * _Width;
        o.uv[4] = uv + (_ScreenParams.zw - 1) * float2(1, -1) * _Width;
                     
        return o;
    }

    int CheckSame(float4 center, float4 sample) {
        float2 centerNormal = center.xy;
        float centerDepth = DecodeFloatRG(center.zw);

        float2 sampleNormal = sample.xy;
        float sampleDepth = DecodeFloatRG(sample.zw);
            
        // 法線方向の差をチェックする
        float2 diffNormal = abs(centerNormal - sampleNormal) * _NormalSensitivity;
        int isSameNormal = (diffNormal.x + diffNormal.y) < 0.1;
        // 深度値の差をチェックする
        float diffDepth = abs(centerDepth - sampleDepth) * _DepthSensitivity;
        int isSameDepth = diffDepth < 0.1 * centerDepth;
            
        // 法線と深度が十分の差があると1を返す
        return isSameNormal * isSameDepth ? 1 : 0;
    }

    float4 Frag(Varyings i) : SV_Target
    {
        float4 sample1 = SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture, i.uv[1]);
        float4 sample2 = SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture, i.uv[2]);
        float4 sample3 = SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture, i.uv[3]);
        float4 sample4 = SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture, i.uv[4]);

        int outline = 1.0;
        outline *= CheckSame(sample1, sample2);
        outline *= CheckSame(sample3, sample4);

        half4 plusOutlineColor = lerp(_Color, SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv[0]), outline);
        half4 onlyOutlineColor = lerp(_Color, half4(1, 1, 1, 1), outline);

        return lerp(plusOutlineColor, onlyOutlineColor, _OutlineOnly);
    }
    ENDHLSL


    SubShader 
    {
        Cull Off 
        ZTest Always
        ZWrite Off

        Pass 
        {
            HLSLPROGRAM
            #pragma vertex Vert  
            #pragma fragment Frag
            ENDHLSL  
        }
    } 
}
