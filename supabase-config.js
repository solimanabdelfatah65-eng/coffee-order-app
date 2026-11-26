// Optional Supabase connection. Add the project URL and public anon key to enable cloud sync.
// Never put a service-role key in a browser-visible file.
window.BON_AL_FOUAD_SUPABASE = (() => {
  const url = "";
  const anonKey = "";
  let clientPromise;

  async function getClient() {
    if (!url || !anonKey) throw new Error("Supabase URL and anon key are not configured.");
    if (!clientPromise) {
      clientPromise = import("https://esm.sh/@supabase/supabase-js@2")
        .then(({ createClient }) => createClient(url, anonKey));
    }
    return clientPromise;
  }

  return {
    get enabled() { return Boolean(url && anonKey); },
    async loadProducts() {
      const client = await getClient();
      const { data, error } = await client.from("products").select("id,name,origin,description,price,image,roast").order("name");
      if (error) throw error;
      return data;
    },
    async loadOrders() {
      const client = await getClient();
      const { data, error } = await client.from("orders").select("*").order("created_at", { ascending: false });
      if (error) throw error;
      return data;
    },
    async saveProducts(products) {
      const client = await getClient();
      const rows = products.map(({ id, name, origin, description, price, image, roast }) =>
        ({ id, name, origin, description, price, image, roast }));
      const { error } = await client.from("products").upsert(rows);
      if (error) throw error;
    },
    async saveOrder(order) {
      const client = await getClient();
      const { error } = await client.from("orders").insert({
        id: order.id,
        customer: order.customer,
        phone: order.phone,
        address: order.address,
        fulfillment: order.fulfillment,
        items: order.items,
        total: order.total,
        status: order.status,
        created_at: order.createdAt
      });
      if (error) throw error;
    }
  };
})();
