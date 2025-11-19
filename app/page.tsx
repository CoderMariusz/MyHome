export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-lg">
      <div className="text-center">
        <h1 className="text-h1 font-bold text-primary mb-lg">
          MyHome
        </h1>
        <p className="text-body text-text-secondary mb-xl">
          Collaborative shopping list for your family
        </p>
        <div className="flex gap-md justify-center">
          <button className="bg-primary text-white px-xl py-md rounded-lg hover:bg-primary-600 transition-colors">
            Get Started
          </button>
          <button className="border border-primary text-primary px-xl py-md rounded-lg hover:bg-primary-50 transition-colors">
            Learn More
          </button>
        </div>
      </div>
    </main>
  );
}
