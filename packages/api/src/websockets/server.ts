import type { WhopServerSdkOptions } from "@/sdk/server-sdk-shared";

export const DEFAULT_WEBSOCKET_ORIGIN = "https://ws-prod.whop.com";

type SendWebsocketMessageInput = {
	message: string;
	target:
		| {
				experience: string;
		  }
		| {
				user: string;
		  }
		| {
				custom: string;
		  }
		| "everyone";
};

export function sendWebsocketMessageFunction(apiOptions: WhopServerSdkOptions) {
	const origin = apiOptions.websocketOrigin ?? DEFAULT_WEBSOCKET_ORIGIN;
	const path = "/v1/websockets/send";
	const url = new URL(path, origin);
	const headers = new Headers();
	headers.set("Content-Type", "application/json");
	headers.set("Authorization", `Bearer ${apiOptions.appApiKey}`);

	return async function SendWebsocketMessage(input: SendWebsocketMessageInput) {
		const response = await fetch(url, {
			method: "POST",
			body: JSON.stringify(input),
			headers,
		});

		if (!response.ok) {
			const error = await response.text();
			throw new Error(
				`Failed to send websocket message. Code: ${response.status}. Message: ${error}`,
			);
		}

		const data = (await response.json()) as { ok: boolean };

		if (!data.ok) {
			throw new Error("Failed to send websocket message");
		}
	};
}
