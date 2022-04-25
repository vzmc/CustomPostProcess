using UnityEditor.Rendering.PostProcessing;
using PostProcess;

namespace Editor
{
    [PostProcessEditor(typeof(Outline))]
    public sealed class OutlineEditor : PostProcessEffectEditor<Outline>
    {
        SerializedParameterOverride color;
        SerializedParameterOverride width;
        SerializedParameterOverride depthSenitivity;
        SerializedParameterOverride normalSenitivity;
        SerializedParameterOverride outlineOnly;

        public override void OnEnable()
        {
            color = FindParameterOverride(x => x.color);
            width = FindParameterOverride(x => x.width);
            depthSenitivity = FindParameterOverride(x => x.depthSenitivity);
            normalSenitivity = FindParameterOverride(x => x.normalSenitivity);
            outlineOnly = FindParameterOverride(x => x.outlineOnly);
        }

        public override void OnInspectorGUI()
        {
            PropertyField(color);
            PropertyField(width);
            PropertyField(depthSenitivity);
            PropertyField(normalSenitivity);
            PropertyField(outlineOnly);
        }
    }
}
