#if UNITY_POST_PROCESSING_STACK_V2
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

namespace PostProcess
{
    [Serializable]
    [PostProcess(typeof(OutlineRenderer), PostProcessEvent.BeforeTransparent, "Custom/Outline")]
    public sealed class Outline : PostProcessEffectSettings
    {
        [ColorUsage(true), Tooltip("Outline's color.")]
        public ColorParameter color = new ColorParameter { value = Color.black };
        [Range(0f, 5f), Tooltip("Outline's width")]
        public FloatParameter width = new FloatParameter { value = 1.0f };
        [Range(0f, 2f), Tooltip("Depth senitivity")]
        public FloatParameter depthSenitivity = new FloatParameter { value = 1.0f };
        [Range(0f, 2f), Tooltip("Normal senitivity")]
        public FloatParameter normalSenitivity = new FloatParameter { value = 1.0f };
        [Range(0f, 1f), Tooltip("Show outline only")]
        public FloatParameter outlineOnly = new FloatParameter { value = 0.0f };
    }

    public sealed class OutlineRenderer : PostProcessEffectRenderer<Outline>
    {
        public override void Render(PostProcessRenderContext context)
        {
            var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/Outline"));

            sheet.properties.SetColor("_Color", settings.color);
            sheet.properties.SetFloat("_Width", settings.width);
            sheet.properties.SetFloat("_DepthSensitivity", settings.depthSenitivity);
            sheet.properties.SetFloat("_NormalSensitivity", settings.normalSenitivity);

            sheet.properties.SetFloat("_OutlineOnly", settings.outlineOnly);

            //ビュー空間の法線をワールド空間に変換するための行列
            //var viewToWorld = Camera.main.cameraToWorldMatrix;
            //sheet.properties.SetMatrix("_ViewToWorld", viewToWorld);

            context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
        }
    }
}
#endif
