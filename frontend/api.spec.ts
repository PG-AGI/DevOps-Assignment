test('backend api reachable', async ({ request }) => {
  const res = await request.get(process.env.NEXT_PUBLIC_API_URL + '/health');
  expect(res.ok()).toBeTruthy();
});

