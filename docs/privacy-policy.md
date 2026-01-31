---
title: Privacy Policy
layout: default
permalink: /privacy-policy/
---

{% capture policy_text %}
This Privacy Policy explains how Roblox UGC Creator (the "App", "we", "us") collects, uses, and shares information. If you do not agree, do not use the App.

## 1) Information We Collect

We collect the following categories of information:

- **Account information**: Email address and basic profile fields from Supabase Auth.
- **Roblox OAuth data**: Roblox user ID, username, avatar URL, and OAuth tokens (access/refresh).
- **User content**: AI prompts, generated 3D assets, textures, and metadata you choose to submit.
- **Usage data**: Basic logs about feature usage, job status, and error reporting.
- **Device data**: App version and platform (iOS/Android) for debugging.

## 2) How We Use Information

We use your information to:

- Provide authentication and account access.
- Generate 3D assets using AI providers.
- Connect your Roblox account and publish assets.
- Improve the App's reliability and performance.

## 3) Legal Basis (where required)

We process your data to provide the App, comply with legal obligations, and improve services. If required by law, you may have additional rights described below.

## 4) Third-Party Services

We use third-party services to deliver core functionality:

- **Supabase** for authentication, database, and storage.
- **Roblox Open Cloud** for OAuth and asset publishing.
- **Meshy** and **Tripo** for AI model generation.

These providers process data only to deliver the requested services.

## 5) Sharing

We do not sell personal information. We only share data with service providers needed to operate the App, or when required by law.

## 6) Data Retention

We retain account data and generated assets while your account is active. You can request deletion of your account and related data.

## 7) Security

We use industry-standard security practices. Secrets are stored server-side and not in the mobile app.

## 8) Children's Privacy

The App is not intended for users under the age required by Roblox for OAuth access. If you believe a minor has used the App without consent, contact us.

## 9) Your Choices

You can:

- Disconnect Roblox OAuth access at any time.
- Request account deletion.
- Request a copy or correction of your data where applicable.

## 10) International Transfers

Your data may be processed in regions where our service providers operate. We use standard protections for data transfers where required.

## 11) Changes

We may update this Policy. We will post updates on this page and adjust the "Last updated" date.

## 12) Contact

For privacy questions, contact:

- Email: mirzasimsek999@gmail.com
{% endcapture %}

<div class="policy-container">
  <div class="policy-header">
    <span class="pill">Legal</span>
    <h1 class="policy-title">Privacy Policy</h1>
    <p class="policy-updated">Last updated: January 31, 2026</p>
  </div>

  <div class="policy-content">
    {{ policy_text | markdownify }}
  </div>
</div>
