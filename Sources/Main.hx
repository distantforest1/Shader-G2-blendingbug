package;

import kha.Color;
import kha.Framebuffer;
import kha.Image;
import kha.Scaler;
import kha.Scheduler;
import kha.Shaders;
import kha.System;
import kha.Assets;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;

class Main {
	static var backbuffer:Image;
	static var x = 0.0;
	static var x2 = 200.0;
	static var xd = 3.5;
	static var x2d = 2.0;
	static var pipeline:PipelineState;

	public static function init() {}

	static function render(frames:Array<Framebuffer>):Void {
		var g = frames[0].g2;
		g.begin(true, Color.fromFloats(0.5, 0.5, 0.5));

		g.pipeline = pipeline;
		if (Assets.images.star_glow != null) {
			g.color = Color.Red;
			g.drawImage(Assets.images.star_glow, x, 50);
			g.color = Color.Green;
			g.drawImage(Assets.images.star_glow, x2, 50);
		}
		g.end();
	}

	static function update():Void {
		x += xd;
		x2 += x2d;
		var bounceL:Float = -50;
		var bounceR:Float = 580;
		if (x > bounceR) {
			x = bounceR;
			xd *= -1;
		} else if (x < bounceL) {
			x = bounceL;
			xd *= -1;
		}
		if (x2 > bounceR) {
			x2 = bounceR;
			x2d *= -1;
		} else if (x2 < bounceL) {
			x2 = bounceL;
			x2d *= -1;
		}
	}

	// Copy this function for custom G2 image shaders
	static function createPipeline():Void {
		pipeline = new PipelineState();
		var structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float32_3X);
		structure.add("vertexUV", VertexData.Float32_2X);
		structure.add("vertexColor", VertexData.UInt8_4X_Normalized);
		pipeline.inputLayout = [structure];
		pipeline.vertexShader = Shaders.painter_image_vert;
		pipeline.fragmentShader = Shaders.postprocess_frag;
		pipeline.compile();

		pipeline.blendSource = kha.graphics4.BlendingFactor.SourceAlpha;
		pipeline.blendDestination = kha.graphics4.BlendingFactor.BlendOne;
		// pipeline.compile(); // <<=== This needs to be uncommented for windows targets for the additive to work
	}

	public static function main() {
		System.start({title: "Shader-G2", width: 1024, height: 768}, function(_) {
			backbuffer = Image.createRenderTarget(1024, 768);
			createPipeline();
			Assets.loadEverything(() -> {
				init();
			});
			System.notifyOnFrames(render);
			Scheduler.addTimeTask(update, 0, 1 / 60);
		});
	}
}
