window.AL_FOUAD_SUPABASE = (() => {
  const url = "https://xniilkeiaygntssuixwd.supabase.co";
  const anonKey = "sb_publishable_1F-0FJZVT1NY9lD7mg3ZRw_kPfIK3jO";
  let clientPromise;

  async function getClient() {
    if (!clientPromise) {
      clientPromise = import("https://esm.sh/@supabase/supabase-js@2")
        .then(({ createClient }) => createClient(url, anonKey));
    }
    return clientPromise;
  }

  async function unwrap(result) {
    if (result.error) throw result.error;
    if (result.data && !Array.isArray(result.data) && (result.data.success === false || result.data.ok === false)) {
      throw new Error(result.data.message || result.data.error || "تعذر تنفيذ طلب قاعدة البيانات.");
    }
    return result.data;
  }

  return {
    async loadCatalog() {
      const client = await getClient();
      const [products, options] = await Promise.all([
        client.from("roastery_products").select("*").eq("active", true).order("sort_order", { ascending: true }),
        client.from("roastery_options").select("*").eq("active", true)
      ]);
      return {
        products: await unwrap(products),
        options: await unwrap(options)
      };
    },
    async submitOrder(order) {
      const client = await getClient();
      return unwrap(await client.rpc("submit_roastery_order", {
        p_customer_name: order.customerName,
        p_customer_phone: order.phone,
        p_fulfillment: order.fulfillment,
        p_address: order.address,
        p_notes: order.notes,
        p_items: order.items
      }));
    },
    async roasteryApi(action, pin, payload) {
      const client = await getClient();
      return unwrap(await client.rpc("roastery_api", {
        p_action: action,
        p_pin: pin,
        p_payload: payload || {}
      }));
    }
  };
})();
