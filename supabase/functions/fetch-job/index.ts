import "@supabase/functions-js/edge-runtime.d.ts";

function extractCompanyLogo(html: string): string | null {
  const patterns = [
    /<img[^>]*class="[^"]*top-card-layout__entity-image[^"]*"[^>]*data-delayed-url="([^"]+)"/,
    /<img[^>]*data-delayed-url="([^"]+)"[^>]*class="[^"]*top-card-layout__entity-image[^"]*"/,
    /<img[^>]*class="[^"]*artdeco-entity-image[^"]*"[^>]*data-delayed-url="([^"]+)"/,
    /<img[^>]*data-delayed-url="([^"]+)"[^>]*class="[^"]*artdeco-entity-image[^"]*"/,
    /<img[^>]*class="[^"]*artdeco-entity-image[^"]*"[^>]*src="([^"]+)"/,
  ];

  for (const pattern of patterns) {
    const match = html.match(pattern)?.[1];
    if (match) {
      return match.replace(/&amp;/g, "&");
    }
  }

  const ogImage = html.match(/<meta[^>]*property="og:image"[^>]*content="([^"]+)"/)?.[1];
  return ogImage?.replace(/&amp;/g, "&") ?? null;
}

export default {
  fetch: async (req: Request) => {
    if (req.method === "OPTIONS") {
      return new Response(null, {
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Headers": "authorization, content-type",
        },
      });
    }

    const { url } = await req.json();

    if (!url) {
      return Response.json({ error: "URL is required" }, { status: 400 });
    }

    const jobIdMatch = url.match(/\/jobs\/view\/(\d+)/);
    if (!jobIdMatch) {
      return Response.json({ error: "Invalid LinkedIn job URL" }, { status: 400 });
    }

    const jobId = jobIdMatch[1];

    const response = await fetch(
      `https://www.linkedin.com/jobs-guest/jobs/api/jobPosting/${jobId}`,
      {
        headers: {
          "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
          "Accept": "text/html,application/xhtml+xml",
          "Accept-Language": "en-US,en;q=0.9",
        },
      }
    );

    if (!response.ok) {
      return Response.json({ error: "Failed to fetch job", status: response.status }, { status: 500 });
    }

    const html = await response.text();

    const title = html.match(/<h2[^>]*class="[^"]*top-card-layout__title[^"]*"[^>]*>([^<]+)<\/h2>/)?.[1]?.trim();
    const company = html.match(/<a[^>]*class="[^"]*topcard__org-name-link[^"]*"[^>]*>([^<]+)<\/a>/)?.[1]?.trim();
    const location = html.match(/<span[^>]*class="[^"]*topcard__flavor--bullet[^"]*"[^>]*>([^<]+)<\/span>/)?.[1]?.trim();
    const companyLogo = extractCompanyLogo(html);
    const descMatch = html.match(/<div[^>]*class="[^"]*description__text[^"]*"[^>]*>([\s\S]*?)<\/div>/);
    const description = descMatch?.[1]
      ?.replace(/<[^>]+>/g, " ")
      ?.replace(/\s+/g, " ")
      ?.trim();

    return Response.json({
      title: title ?? null,
      company: company ?? null,
      companyLogo: companyLogo,
      location: location ?? null,
      description: description ?? null,
    }, {
      headers: { "Access-Control-Allow-Origin": "*" },
    });
  },
};
