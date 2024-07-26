import React from 'react';
import Footer from './Footer';
import Nav from './Nav';
import Hero from './Hero';

const Home = () => {
  return (
    <div className="min-h-screen bg-gray-100">
      <Nav />
      <Hero/>
      <Footer />
    </div>
  );
};

export default Home;
