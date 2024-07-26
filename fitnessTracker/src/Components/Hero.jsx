import React from "react";

function Hero(){
    return(
        <main className="container mx-auto px-4 py-8">
        <section className="text-center mb-12">
          <h2 className="text-4xl font-bold mb-4">Welcome to Your Fitness Tracker</h2>
          <p className="text-lg text-gray-700">Track your activities, monitor your progress, and achieve your fitness goals with ease.</p>
        </section>
        <section className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          <div className="bg-white p-6 rounded-lg shadow-md">
            <h3 className="text-2xl font-bold mb-2">Track Activities</h3>
            <p className="text-gray-700">Record your workouts and daily activities to stay on top of your fitness journey.</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-md">
            <h3 className="text-2xl font-bold mb-2">Monitor Progress</h3>
            <p className="text-gray-700">Analyze your performance and progress over time with detailed statistics and charts.</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-md">
            <h3 className="text-2xl font-bold mb-2">Set Goals</h3>
            <p className="text-gray-700">Define your fitness goals and milestones to keep yourself motivated and focused.</p>
          </div>
        </section>
      </main>
    )
}

export default Hero;