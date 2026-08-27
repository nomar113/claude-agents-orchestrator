import { withBrowserContext, getOpenContextCount, closeBrowser } from '../../src/browser/browser-manager';

jest.setTimeout(30_000);

afterAll(async () => {
  await closeBrowser();
});

describe('browser-manager', () => {
  it('opens and closes a context around the callback', async () => {
    expect(getOpenContextCount()).toBe(0);
    await withBrowserContext(async () => {
      expect(getOpenContextCount()).toBe(1);
    });
    expect(getOpenContextCount()).toBe(0);
  });

  it('closes the context even when the callback throws', async () => {
    await expect(
      withBrowserContext(async () => {
        throw new Error('boom');
      }),
    ).rejects.toThrow('boom');
    expect(getOpenContextCount()).toBe(0);
  });

  it('supports concurrent contexts', async () => {
    const first = withBrowserContext(async () => {
      await new Promise((resolve) => setTimeout(resolve, 50));
      return 'first';
    });
    const second = withBrowserContext(async () => {
      expect(getOpenContextCount()).toBe(2);
      return 'second';
    });
    await Promise.all([first, second]);
    expect(getOpenContextCount()).toBe(0);
  });
});
