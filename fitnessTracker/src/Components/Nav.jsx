import React from "react";

function Nav(){
    return(
        <header className="bg-blue-600 text-white py-4">
        <div className="container mx-auto flex justify-between items-center">
          <h1 className="text-2xl font-bold">Fitness Tracker</h1>
          <nav>
            <a href="#" className="px-3 py-2 hover:bg-blue-700 rounded">Home</a>
            <a href="#" className="px-3 py-2 hover:bg-blue-700 rounded">Dashboard</a>
            <a href="#" className="px-3 py-2 hover:bg-blue-700 rounded">Profile</a>
            <a href="#" className="px-3 py-2 hover:bg-blue-700 rounded">Sign Out</a>
          </nav>
        </div>
      </header>
    )
}

export default Nav;