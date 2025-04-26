#include <android_native_app_glue.h>
#include <android/log.h>
#include <jni.h>

void handle_cmd(struct android_app *app, int32_t cmd) {}
void android_main(struct android_app *app) {
	(void)__android_log_print(ANDROID_LOG_INFO, "barebones", "Barebones Android app says hello!");
	app->onAppCmd = handle_cmd;
	while (!app->destroyRequested) {
		struct android_poll_source *source;
		int events;
		switch (ALooper_pollOnce(-1, 0, &events, (void **)&source)) {
			default: if (source) source->process(app, source);
		}
	}
}
